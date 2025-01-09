downloadsUI <- function() {
   nav_menu(
      "Downloads",
      nav_item(downloadButton("dag", "Download DAG Image", icon = icon("download"))),
      nav_item(downloadButton("backdoorDag", "Download Backdoor DAG", icon = icon("download"))),
      nav_item(downloadButton("legendDownload", "Download DAG Legend", icon = icon("download"))),
      nav_item(actionButton("downloadRCode", "Copy R-Code to Clipboard", icon = icon("copy")))
   )
}
