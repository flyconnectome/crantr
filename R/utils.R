# hidden
append_status <- function(status, update){
  status=paste(c(status,update),collapse=",")
  update.col<-paste(sort(unique(unlist(strsplit(status,split=",|, ")))),collapse=",")
  gsub("^,| ","",update.col)
}

# hidden
subtract_status <- function(status, update, invert = FALSE){
  statuses <- sort(unique(unlist(strsplit(status,split=",|, "))))
  if(invert){
    statuses <- sort(unique(intersect(statuses,update)))
  }else{
    statuses <- sort(unique(setdiff(statuses,update)))
  }
  update.col<-paste0(statuses,collapse=",")
  gsub("^,| ","",update.col)
}
