displayNodesUI <- function(id) {
  ns <- NS(id)
  
  fluidPage(
     style = "width: 250px; overflow-x: hidden; padding: 0;",  # Fixed width and padding
     uiOutput(ns("addNodeForm")),
     div(
        style = "width: 100%; padding: 0;",  # Ensure div fills the container width with no extra padding
        fluidRow(
           div(
              style = "border-bottom: solid; color: var(--fg); display: flex; align-items: center; gap: 10px;",
              
              # Buttons beside the text
              div(
                 style = "display: flex; gap: 5px;",  # Adds spacing between buttons
                 circleButton(ns("newNode"), icon = icon("add"), size = "xs",
                              style = "border: 1px solid var(--fg);",
                              class = "themeButton"),
                 circleButton(ns("renameNodes"), icon = icon("edit"), size = "xs",
                              style = "border: 1px solid var(--fg);",
                              class = "themeButton")
              ),
              h2("Nodes", style = "margin: 0;")  # Ensures h2 has no extra margins
           )
        ),
        p("Click on a node card to condition on it", style = "color: var(--fg); padding-left: 0; padding-top: 5px"),
        div(
           style = "height: 400px; overflow-y: auto; overflow-x: hidden; padding-left: 0; margin-left: 0;",  # Remove padding and margin
           uiOutput(ns("nodeBoxes"))
        )
     )
  )
}




# displayNodesUI <- function(id) {
#   ns <- NS(id)
#   
#   fluidPage(
#     uiOutput(ns("addNodeForm")),
#       column(10, 
#         fluidRow(
#           h2("Nodes", style = "display: inline-block;
#                                border-bottom: solid;
#                                color: var(--fg)
#              "),
#           circleButton(ns("newNode"), icon = icon("add"), size = "xs",
#                      style = "display: inline-block;
#                               border: 1px solid var(--fg);",
#                      class = "themeButton"),
#           circleButton(ns("renameNodes"), icon = icon("edit"), size = "xs",
#                        style = "display: inline-block;
#                                 border: 1px solid var(--fg);",
#                        class = "themeButton")
#         ),
#         p("Click on a node card to condition on it", style = "color: var(--fg);"),
#         div(
#           style = "height: 400px; overflow-y: scroll;",
#           uiOutput(ns("nodeBoxes"))
#         )
#       ),
#   )
# }