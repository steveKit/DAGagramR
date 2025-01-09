createUI <- function(theme) {
   page_navbar(
      theme = theme,
      header = headerUI(),
      useShinyjs(),
      nav_panel(
         "Main",
         fluidRow(
            sidebarUI(),
            mainContentUI(),
            versionHistoryUI()
         )
      ),
      nav_panel(
         "Downloads",
         downloadsUI()
      )
   )
}

