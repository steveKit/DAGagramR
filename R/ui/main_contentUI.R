mainContentUI <- function() {
   column(
      width = 9,
      card(
         full_screen = TRUE,
         controlsUI(),
         graphUI()
      )
   )
}

controlsUI <- function() {
   fluidRow(
      div(
         style = "width: 90%;",
         materialSwitch(
            inputId = "showBackdoor",
            label = "Show Open Backdoor Paths",
            status = "primary",
            right = TRUE
         ),
         uiOutput("effectModifierSwitch")
      ),
      div(
         style = "width: 10%;",
         actionButton("refreshLayout", NULL, icon = icon("refresh"))
      )
   )
}

graphUI <- function() {
   div(
      style = "width: 100%; margin-top: 0px;",
      uiOutput("graph")
   )
}
