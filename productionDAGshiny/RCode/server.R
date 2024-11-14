RCodeServer <- function(input, output, session, toDataStorage, dagDownloads){
  ns <- session$ns
  
  observe({
    dagString <- DataToDag(toDataStorage$data)
    dagDownloads$RCode <- dagString
  })
}
