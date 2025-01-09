versionHistoryUI <- function() {
   card("Version History",
        div(tags$h1("Version History")),
        div(
           tags$ul(
              tags$li("Version 0.1.1 - Updated copy & paste functions, added tooltips, and revised layout"),
              tags$li("Version 0.1.0 - Initial Alpha release")
           )
        )
   )
}
