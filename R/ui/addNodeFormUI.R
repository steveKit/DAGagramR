addNodeUI <- function(id) {
   ns <- NS(id)
   
   tagList(
      uiOutput(ns("errorMessage")),
      uiOutput(ns("errorMessage2")),
      uiOutput(ns("errorText")),
      
      textInput(ns("name"), "Node Name"),
      
      radioButtons(
         ns("unmeasured"),
         "Node Type",
         choices = c("measured", "unmeasured"),
         selected = "measured"
      ),
      
      uiOutput(ns("checkboxGroupFrom")),
      uiOutput(ns("checkboxGroupTo")),
      
      actionButton(ns("add_node"), "Add Node")
   )
}
