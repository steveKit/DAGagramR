openDAGUI <- function(id) {
  ns <- NS(id)
  fluidPage(
    fluidRow(
      column(4,
             offset = 8,
             style = "margin:1em; padding:0;",
             grVizOutput(ns("dagLegend"), height = 100, width = 190)
      )),
    grVizOutput(ns("coloredDag"), width = "100%", height = "400px"),
    uiOutput(ns("conditioningWarning")),
    div(
      style = "text-align: right;",
    ),
    uiOutput(ns("openPaths")),
    uiOutput(ns("unmeasuredWarning"))
  )
}