renameNodesServer <- function(id, toDataStorage, treatment, response,
                              highlightedPathList, observerInitialized) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    baseList <- c(treatment(), response(), "participation")
    AllInputs <- reactive({NULL})
    
    output$renaming <- renderUI({
      Map(function(n) {
        uniquUiId <- ns(n)
        fluidRow(
          column(1, checkboxInput(paste0(uniquUiId, "remove"),  label = NULL)),
          column(5, h6(n)),
          column(6, textInput(uniquUiId, NULL, value = n))
        )
      }, sort(unique(toDataStorage$data$name)))
    })
    
    # Create observe Event only once
    if (!observerInitialized()) {
      observeEvent(input$renameNodes, {
        # Remove deleted Nodes 
        checkedNames <- sapply(sort(unique(toDataStorage$data$name)), function(n) {
          # Access the check box state
          input[[paste0(n, "remove")]]  
        })
        
        selectedDelete <- names(checkedNames[checkedNames])
        
        if (any(selectedDelete %in% baseList)) {
          output$errorText <- renderUI({
            p("You cannot delete the base nodes",
              id = "removeBaseNodesError", class = "errorMessage")
          })
        } else {
          temp <- toDataStorage$data %>%
            filter(!(name %in% selectedDelete)) %>%
            mutate(to = if_else(to %in% selectedDelete, NA_character_, to))
          
          toDataStorage$data <- temp
          
          # Rename Nodes
          # Map each name to new name in toDataStorage()
          
          # Turn all new name inputs into a list
          AllInputs <- reactive({
            x <- reactiveValuesToList(input)
            data.frame(
              names = names(x),
              values = unlist(x, use.names = FALSE)
            )
          })
          
          temp <- AllInputs() %>%
            slice(-1) %>%
            filter(names %in% toDataStorage$data$name)
          
          newNameList <- temp$values
          
          badNameList <- c()
          
          # Make sure all new names are unique
          uniqueNames <- unique(newNameList)
          uniqueSubmit <- length(uniqueNames) == length(newNameList)
  
          # Make sure names follow guidelines
          for (name in newNameList) {
            nameCheck <- CheckNameInput(name)
            
            if (!(nameCheck$isValid)) {
              badNameList <- c(badNameList, name)
            }
          }
          
          cleanNamesubmit <- length(badNameList) < 1
          
          if (cleanNamesubmit & uniqueSubmit) {
            tempToStorage <- toDataStorage$data
            
            mergedTemp <- tempToStorage %>%
              left_join(temp, by = c("name" = "names")) %>%
              left_join(temp, by = c("to" = "names"), suffix = c("_name", "_to")) %>%
              mutate(
                base = case_when(name == treatment() ~ "treatment",
                               name == response() ~ "response"),
                name = coalesce(values_name, name),
                to = coalesce(values_to, to)
              ) %>%
              select(-c(values_name, values_to))
            
            # Sets new global variables
            tempTreatment <- mergedTemp$name[mergedTemp$base == "treatment"]
            tempTreatment <- tempTreatment[!is.na(tempTreatment)][1]
            tempResponse <- mergedTemp$name[mergedTemp$base == "response"]
            tempResponse <- tempResponse[!is.na(tempResponse)][1]
            
            treatment(tempTreatment)
            response(tempResponse)
            
            toDataStorage$data <- mergedTemp %>%  mutate(
              base = if_else(
                name %in% c(treatment(), response(), "participation"),
                TRUE, FALSE)
              )
            
            
            # Remove the modal after the operation
            removeModal()
          } else if (cleanNamesubmit) {
            output$errorText <- renderUI({
              p("Each node must have a unique name",
                id = "uniqueNameError", class = "errorMessage")
            })
            runjs("setTimeout(function() { $('#uniqueNameError').fadeOut(); }, 3000);")
          } else {
            output$errorText <- renderUI({
              column(12,
                p("The following nodes don't follow the name rules",
                  id = "namingError", class = "errorMessage"),
                p(paste(badNameList, collapse = ", "), id = "namingError")
              )
            })
            runjs("setTimeout(function() { $('#namingError').fadeOut(); }, 3000);")
          }
        }
      })
      
      # Set the flag to TRUE to prevent re-creation
      observerInitialized(TRUE)
      
    }
  })
}
