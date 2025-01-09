sidebarUI <- function() {
   column(
      width = 3,
      style = "max-width: 300px;",
      card(
         full_screen = TRUE,
         displayNodesUI("displayNodes")
      )
   )
}
