welcomeModalUI <- function() {
   modalDialog(
      tags$p("Welcome to DAGagramR", 
             style = "font-size: 2rem; font-weight: bold; margin-bottom: 20px; text-align: center;"),
      h5("Please enter the initial settings for your DAG.",
         tooltip(
            bsicons::bs_icon("info-circle-fill", title = "Name Rules"),
            "Node names can be up to 14 characters, no spaces, and no special characters."
         ),
         style = "margin-top: 5px; margin-bottom: 15px; text-align: left;"),
      textInput("treatmentName", "Treatment Name", ""),
      textInput("responseName", "Response Name", ""),
      checkboxInput("transportability", "Enable Transportability?", FALSE),
      footer = tagList(
         modalButton("Cancel"),
         actionButton("setNames", "Start")
      )
   )
}
