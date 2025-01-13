server <- function(input, output, session) {

   # Initialize modal
   modalValues <- callModule(welcomeModalServer, "welcomeModal")

   # Handle modal form submission
   observeEvent(input$setNames, {
      if (CheckNameInput(input$treatmentName)$isValid & CheckNameInput(input$responseName)$isValid) {
         removeModal()

         # Set up reactive values for inputs
         treatment <- reactiveVal(input$treatmentName)
         response <- reactiveVal(input$responseName)
         highlightedPathList <- reactiveVal(NULL)
         isTransportability <- reactiveVal(input$transportability)

         if (isTransportability()) {
            toDataStorage <- reactiveValues(
               data = data.frame(
                  name = I(c(response(), treatment(), "Participation")),
                  to = I(c(NA, response(), NA)),
                  unmeasured = FALSE,
                  conditioned = FALSE,
                  base = TRUE,
                  effectModifier = FALSE
               )
            )

            # Add the effect modifier switch
            output$effectModifierSwitch <- renderUI({
               effectModifierSwitchUI()
            })

         } else {
            toDataStorage <- reactiveValues(
               data = data.frame(
                  name = I(c(response(), treatment())),
                  to = I(c(NA, response())),
                  unmeasured = FALSE,
                  conditioned = FALSE,
                  base = TRUE,
                  effectModifier = FALSE
               )
            )
         }

         dagDownloads <- reactiveValues(
            dag = NULL,
            backdoorDag = NULL,
            legend = NULL,
            RCode = "This is your R code" # Replace this with your actual R code to be copied
         )

         effectModifierShow <- reactiveVal(FALSE)
         openDAGUI("openDAG")
         backdoorShow <- reactiveVal(FALSE)
         layout <- reactiveVal("kk")

         observe({
            openDAGUI("openDAG")
            backdoorShow(input$showBackdoor)
            if (!is.null(input$showEffectModifiers)){
               effectModifierShow(input$showEffectModifiers)
            }

            output$graph <- renderUI({
               openDAGUI("openDAG")
            })
         })

         observeEvent(input$refreshLayout, {
            if (layout() == "kk") {
               layout("tree")
            } else if (layout() == "tree") {
               layout("circle")
            } else {
               layout("kk")
            }
         })

         displayNodesServer("displayNodes", toDataStorage, treatment, response, highlightedPathList)
         dagVisualizationServer("openDAG", toDataStorage,
                       treatment, response, highlightedPathList, isTransportability,
                       dagDownloads, backdoorShow, effectModifierShow, layout)
         generateDAGCode(input, output, session, toDataStorage, dagDownloads)

         # Handle download buttons
         output$dag <- downloadHandler(
            filename = function() { paste0("dag", ".png") },
            content = function(file) {
               export_graph(dagDownloads$dag, file_name = file, file_type = "png", width = 4000, height = 3000)
            }
         )

         output$backdoorDag <- downloadHandler(
            filename = function() { paste0("backdoorDag", ".png") },
            content = function(file) {
               export_graph(dagDownloads$backdoorDag, file_name = file, file_type = "png", width = 4000, height = 3000)
            }
         )

         output$legendDownload <- downloadHandler(
            filename = function() { paste0("dagLegend", ".png") },
            content = function(file) {
               export_graph(dagDownloads$legend, file_name = file, file_type = "png", width = 4000, height = 3000)
            }
         )

         observeEvent(input$downloadRCode, {
            session$sendCustomMessage("copyToClipboard", dagDownloads$RCode)
            showNotification("R code copied to clipboard", type = "message")
         })

      } else {
         output$nameError <- renderUI({
            p("The names must follow the naming convention",
              id = "nameError", class = "errorMessage")
         })
         runjs("setTimeout(function() { $('#nameError').fadeOut(); }, 3000);")
      }
   })
}