#!/usr/bin/env python
"""Download a whole CAVE synapse table (one materialisation version) as parquet
chunks, in parallel and restartably.

Each chunk is one id range [lo, lo + width) written to
<outdir>/chunk-<lo>.parquet via a tmp file, so a chunk file exists only when it
is complete. Rerunning with the same outdir skips finished chunks and retries
failed ones; the materialisation version, columns and chunk width are fixed by
<outdir>/manifest.json on the first run.

--fraction < 1 fetches every 1/fraction-th chunk, spread over the table; a later
run with --fraction 1 fills in the rest.

Examples:
  python synapse-cave-download.py OUTDIR --fraction 0.05 --threads 4
  python synapse-cave-download.py OUTDIR --status
"""
import argparse, datetime, glob, json, logging, os, random, signal, sys, threading, time
from concurrent.futures import ThreadPoolExecutor, as_completed

import pyarrow as pa
import pyarrow.parquet as pq
from caveclient import CAVEclient

DATASTACK = "kronauer_ant"
SERVER = "https://proofreading.zetta.ai"
COLS = ["id", "size", "pre_pt_supervoxel_id", "post_pt_supervoxel_id",
        "pre_pt_root_id", "post_pt_root_id", "pre_pt_position", "post_pt_position"]
ROW_LIMIT = 500000  # server limit on rows per query
WAIT = [10, 30, 60, 120, 300]
TIMEOUT = (30, 180)  # connect, read (s); a chunk normally takes about 20 s

# caveclient logs the server's warning whenever a query is limited (as every
# max_id() probe is); fetch_chunk() checks row counts itself
class _NoLimitWarning(logging.Filter):
    def filter(self, record):
        return "Limited query" not in record.getMessage()
logging.getLogger("caveclient.base").addFilter(_NoLimitWarning())

_local = threading.local()


def client(reset=False):
    """One CAVEclient per thread. caveclient sets no timeout on its requests,
    so a stalled connection would hang the thread for ever: give the
    materialisation session a default one, so that fetch_chunk() retries."""
    if reset or getattr(_local, "client", None) is None:
        cl = CAVEclient(DATASTACK, server_address=SERVER)
        s = cl.materialize.session
        request = s.request
        def request_with_timeout(*a, **kw):
            kw.setdefault("timeout", TIMEOUT)
            return request(*a, **kw)
        s.request = request_with_timeout
        _local.client = cl
    return _local.client


def pick_version(cl, version=None):
    """The given version, or the valid available one with the longest life."""
    vv = [m for m in cl.materialize.get_versions_metadata()
          if m["valid"] and m["status"] == "AVAILABLE"]
    if version is not None:
        vv = [m for m in vv if m["version"] == version]
    if not vv:
        sys.exit("No usable materialisation version" +
                 ("" if version is None else " %d" % version))
    return max(vv, key=lambda m: m["expires_on"])


def max_id(cl, table, version):
    """Exact max id, by bisection: ids > lo exist, ids > hi do not."""
    def above(x):
        # selecting only id fails server side, hence size as well
        return len(cl.materialize.query_table(
            table, filter_greater_dict={"id": int(x)}, select_columns=["id", "size"],
            limit=1, materialization_version=version)) > 0
    lo, hi = 0, 1
    while above(hi):
        lo, hi = hi, hi * 2
    while hi - lo > 1:
        mid = (lo + hi) // 2
        if above(mid):
            lo = mid
        else:
            hi = mid
    return hi


def chunk_path(outdir, lo):
    return os.path.join(outdir, "chunk-%010d.parquet" % lo)


def fetch_chunk(man, lo, path, tries):
    tmp = path + ".tmp"
    hi = lo + man["width"]
    msg = ""
    for attempt in range(tries):
        t0 = time.time()
        try:
            df = client(reset=attempt > 0).materialize.query_table(
                man["table"], filter_greater_dict={"id": lo - 1},
                filter_less_dict={"id": hi}, select_columns=man["cols"],
                materialization_version=man["version"], split_positions=True)
            if len(df):
                if df["id"].min() < lo or df["id"].max() >= hi:
                    raise ValueError("ids outside chunk range")
                if df["id"].duplicated().any():
                    raise ValueError("duplicate ids")
                if len(df) >= ROW_LIMIT:
                    raise ValueError("%d rows: hit the server row limit" % len(df))
            df = df.sort_values("id")
            pq.write_table(pa.Table.from_pandas(df, preserve_index=False), tmp,
                           compression="zstd")
            os.replace(tmp, path)
            return dict(lo=lo, ok=True, rows=len(df), bytes=os.path.getsize(path),
                        secs=time.time() - t0)
        except Exception as e:
            msg = "%s: %s" % (type(e).__name__, str(e)[:300])
            if os.path.exists(tmp):
                os.remove(tmp)
            if attempt + 1 < tries:
                print(time.strftime("%H:%M:%S ") + "chunk %d attempt %d failed, retrying: %s"
                      % (lo, attempt + 1, msg[:120]), flush=True)
                time.sleep(WAIT[min(attempt, len(WAIT) - 1)] * random.uniform(0.75, 1.25))
    return dict(lo=lo, ok=False, msg=msg)


def load_manifest(outdir, args):
    mf = os.path.join(outdir, "manifest.json")
    if os.path.exists(mf):
        with open(mf) as f:
            man = json.load(f)
        if (args.table not in (None, man["table"]) or args.width not in (None, man["width"])
                or args.version not in (None, man["version"])):
            sys.exit(mf + " is for a different table, version or width")
        return man
    cl = client()
    table = args.table or cl.materialize.synapse_table
    v = pick_version(cl, args.version)
    print("Finding max id in %s v%d" % (table, v["version"]), flush=True)
    man = dict(datastack=DATASTACK, table=table, version=v["version"],
               timestamp=v["time_stamp"].isoformat(), cols=COLS,
               width=args.width or 200000, max_id=max_id(cl, table, v["version"]),
               created=datetime.datetime.now(datetime.timezone.utc).isoformat())
    if man["width"] >= ROW_LIMIT:
        sys.exit("width must be < %d" % ROW_LIMIT)
    with open(mf, "w") as f:
        json.dump(man, f, indent=2)
    return man


def all_los(man):
    return list(range(0, man["max_id"] + 1, man["width"]))


def status(outdir):
    with open(os.path.join(outdir, "manifest.json")) as f:
        man = json.load(f)
    los = all_los(man)
    have = [lo for lo in los if os.path.exists(chunk_path(outdir, lo))]
    rows = sum(pq.read_metadata(chunk_path(outdir, lo)).num_rows for lo in have)
    mb = sum(os.path.getsize(chunk_path(outdir, lo)) for lo in have) / 1e6
    print("%s v%d (%s): %d of %d chunks, %s rows, %.0f MB" % (
        man["table"], man["version"], man["timestamp"], len(have), len(los),
        format(rows, ","), mb))


def main():
    p = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    p.add_argument("outdir")
    p.add_argument("--fraction", type=float, default=1.0)
    p.add_argument("--threads", type=int, default=4)
    p.add_argument("--tries", type=int, default=6)
    p.add_argument("--width", type=int, help="ids per chunk (first run only)")
    p.add_argument("--version", type=int, help="materialisation version (first run only)")
    p.add_argument("--table", help="default: the datastack's synapse table")
    p.add_argument("--status", action="store_true", help="just report progress")
    args = p.parse_args()
    outdir = os.path.expanduser(args.outdir)
    if args.status:
        return status(outdir)
    os.makedirs(outdir, exist_ok=True)
    for f in glob.glob(os.path.join(outdir, "*.tmp")):
        os.remove(f)
    man = load_manifest(outdir, args)

    v = pick_version(client(), man["version"])
    if v["expires_on"].timestamp() < time.time() + 3600:
        sys.exit("Version %d expires within the hour" % man["version"])
    los = all_los(man)
    los = los[::max(1, round(1 / args.fraction))]
    todo = [lo for lo in los if not os.path.exists(chunk_path(outdir, lo))]

    logfile = os.path.join(outdir, "download.log")
    def log(s):
        line = time.strftime("%H:%M:%S ") + s
        print(line, flush=True)
        with open(logfile, "a") as f:
            f.write(line + "\n")
    log("%s v%d (%s, expires %s), max id %d: %d of %d chunks to fetch with %d threads" % (
        man["table"], man["version"], man["timestamp"], v["expires_on"].isoformat(),
        man["max_id"], len(todo), len(los), args.threads))

    # Exit at once on Ctrl-C or kill, without waiting for in-flight requests:
    # finished chunks are complete files, partial ones are only .tmp files.
    def stop(signum, frame):
        log("Stopped by signal %d: finished chunks are kept; rerun to continue" % signum)
        os._exit(130)
    signal.signal(signal.SIGINT, stop)
    signal.signal(signal.SIGTERM, stop)

    t0, done, rows, nbytes, failed = time.time(), 0, 0, 0, []
    ex = ThreadPoolExecutor(max_workers=args.threads)
    futs = [ex.submit(fetch_chunk, man, lo, chunk_path(outdir, lo), args.tries)
            for lo in todo]
    for f in as_completed(futs):
        r = f.result()
        done += 1
        if not r["ok"]:
            failed.append(r["lo"])
            log("chunk %d FAILED: %s" % (r["lo"], r["msg"]))
            continue
        rows += r["rows"]
        nbytes += r["bytes"]
        el = time.time() - t0
        log("%d/%d chunk %d: %d rows in %.0f s | %d rows, %.0f MB, %.0f rows/s, ETA %.0f min" % (
            done, len(todo), r["lo"], r["rows"], r["secs"], rows, nbytes / 1e6,
            rows / el, el / done * (len(todo) - done) / 60))
    ex.shutdown()
    log("Finished: %d rows, %.0f MB in %.1f min; %d failed chunks%s" % (
        rows, nbytes / 1e6, (time.time() - t0) / 60, len(failed),
        "; rerun to retry them" if failed else ""))
    sys.exit(1 if failed else 0)


if __name__ == "__main__":
    main()
