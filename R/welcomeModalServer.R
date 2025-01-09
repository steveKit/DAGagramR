welcomeModalServer <- function(input, output, session) {
   # Show initial modal
   observe({
      showModal(welcomeModalUI())
   })
   
   # Return reactive values that can be used in main server
   return(
      list(
         treatment = reactive(input$treatmentName),
         response = reactive(input$responseName),
         transportability = reactive(input$transportability),
         submitted = reactive(input$setNames)
      )
   )
}
