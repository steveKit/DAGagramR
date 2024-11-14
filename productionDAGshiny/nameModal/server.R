nameModalServer <- function(input, output, session) {
  fields_mandatory <- c("treatmentName", "responseName")
  
  naming_modal <- modalDialog(
    title = tags$div(
      tags$h4("Set Base Names"),
      tags$h6("Name Rules"),
      tags$p(HTML("
                  * Max 14 Characters <br>
                  * No Special Characters <br>
                  * No Spaces"),
             style = "font-size: 12px;")
    ),
    textInput("treatmentName", LabelMandatory("Treatment Name")),
    textInput("responseName", LabelMandatory("Response Name")),
    input_switch("transportability", "Transportability", FALSE),
    actionButton("setNames", "Set Names", class = "btn-primary"),
    uiOutput("nameError"),
    easyClose = FALSE,
    footer = NULL,
    style = "padding-top: 0px;"
  )
  
  showModal(naming_modal)
}
