headerUI <- function() {
   div(
      style = "display: flex; align-items: center; justify-content: space-between; width: 100%;",
      span("DAGagramR v0.1.1"),
      tags$img(src = "CCSlogo.png", height = "35px", style = "margin-right: 10px; margin-left: 10px;")
   )
}
