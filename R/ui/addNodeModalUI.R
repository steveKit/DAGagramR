addNodeModal <- function(ns, newNS) {
   modalDialog(
      fluidPage(
         tags$p("New Node", 
                style = "font-size: 2rem; font-weight: bold; margin-bottom: 20px; text-align: center;"),
         div(
            id = ns(newNS("newNode")),
            fluidRow(
               div(
                  class = "label-container",
                  style = "display: flex; align-items: center; gap: 5px;",
                  h5(LabelMandatory("Name"), style = "margin: 0;"),
                  tooltip(
                     bsicons::bs_icon("info-circle-fill", title = "Name Rules"),
                     "Node names can be up to 14 characters, no spaces, and no special characters."
                  )
               )
            ),
            textInput(ns(newNS("name")), NULL, ""),
            uiOutput(ns(newNS("errorMessage"))),
            radioButtons(ns(newNS("unmeasured")), tags$h5("Type"),
                         c("Measured" = "measured",
                           "Unmeasured" = "unmeasured"
                         )),
            fluidRow(
               h5(LabelMandatory("Connections")),
               column(6,
                      uiOutput(ns(newNS("checkboxGroupTo")))
               ),
               column(6,
                      uiOutput(ns(newNS("checkboxGroupFrom")))
               )
            ),
            br(), br(),
            uiOutput(ns(newNS("errorText"))),
            uiOutput(ns(newNS("errorMessage2")))
         )
      ),
      footer = tagList(
         modalButton("Cancel"),
         actionButton(ns(newNS("add_node")), "Add Node", class = "btn-primary")
      )
   )
}