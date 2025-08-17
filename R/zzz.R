.onLoad <- function(libname, pkgname) {

  # make crant4<->crant3 bridging registrations available
  #register_crant3to4()
  invisible()
}

.onAttach <- function(libname, pkgname) {
  packageStartupMessage(
    'Use `with_crant()` to wrap many additional fafbseg::flywire_* functions for use with the CRANT\n',
    'Alternatively `choose_crant()` to set all flywire_* functions to target the CRANT!\n',
    'Use dr_crant() to get a report on your installation.\n',
    'Use register_crant_coconat(showerror=FALSE) to register ctrantr with coconat for connectivity comparisons.',
    'Trouble? Visit https://natverse.github.io/crantr/SUPPORT.html or #code on crantconnectomics.slack.com Slack')
}
