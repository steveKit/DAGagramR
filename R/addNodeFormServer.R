addNodeServer <- function(id, toDataStorage, treatment, response, highlightedPathList) {
   moduleServer(id, function(input, output, session) {
      ns <- session$ns
      
      output$checkboxGroupTo <- renderUI({
         checkboxGroupInput(
            inputId = ns("children"),
            label = "Children",
            choiceNames = sort(unique(toDataStorage$data$name)),
            choiceValues = sort(unique(toDataStorage$data$name))
         )
      })
      
      output$checkboxGroupFrom <- renderUI({
         from_df <- toDataStorage$data %>% filter(name != response())
         
         checkboxGroupInput(
            inputId = ns("parents"),
            label = "Parents",
            choiceNames = sort(unique(from_df$name)),
            choiceValues = sort(unique(from_df$name))
         )
      })
      
      observe({
         text_filled <- CheckNameInput(input$name)
         overlap <- intersect(input$children, input$parents)
         
         output$errorMessage <- renderUI({
            p(text_filled$errorMessage, class = "errorMessage")
         })
         
         output$errorMessage2 <- renderUI({
            if (length(overlap) > 0) {
               p("A node cannot be both a child and a parent.", class = "errorMessage")
            } else {
               NULL
            }
         })
         
         checkboxes_filled <- (!is.null(input$parents) && length(input$parents) > 0) |
            !is.null(input$children) && length(input$children)
         
         mandatoryFilled <- text_filled$isValid && checkboxes_filled && (length(overlap) == 0)
         
         shinyjs::toggleState(id = "add_node", condition = mandatoryFilled)
      })
      
      observeEvent(input$add_node, {
         if (!(input$name %in% unique(toDataStorage$data$name))) {
            newToDF <- data.frame(
               name = input$name,
               parents = I(list(input$parents)),
               children = I(list(input$children))
            )
            
            unmeasured <- if(input$unmeasured == "measured") FALSE else TRUE
            
            nodeStateDf <- data.frame(
               name = input$name,
               conditioned = FALSE,
               unmeasured = unmeasured
            )
            
            longDF <- ToDataLong(newToDF) %>%
               full_join(nodeStateDf, by = join_by(name))
            
            temp <- toDataStorage$data %>%
               bind_rows(longDF) %>%
               group_by(name) %>%
               mutate(
                  unmeasured = if_else(is.na(unmeasured), first(unmeasured), unmeasured),
                  conditioned = if_else(is.na(conditioned), first(conditioned), conditioned)
               ) %>%
               ungroup()
            
            nodeList <- unique(c(temp$name, temp$to))
            nameList <- unique(temp$name)
            
            alone_df <- data.frame(
               name = setdiff(nodeList, nameList),
               to = NA,
               unmeasured = unmeasured
            ) %>%
               filter(
                  !(is.na(name)) & name != input$name
               )
            
            if (nrow(alone_df) >= 1) {
               temp <- bind_rows(temp, alone_df)
            }
            
            baseList <- c(treatment(), response(), "participation")
            
            temp <- temp %>%
               mutate(base = name %in% baseList)
            
            toDataStorage$data <- temp
            highlightedPathList(NULL)
            
            updateTextInput(session, "name", value = "")
            updateCheckboxInput(session, "unmeasured", value = FALSE)
            updateRadioButtons(session, "unmeasured", selected = "measured")
            
            output$errorText <- renderUI({
               p("")
            })
            
            removeModal()
         } else {
            output$errorText <- renderUI({
               p("Each node must have a unique name",
                 id = "errorMessage", class = "errorMessage")
            })
            
            runjs("setTimeout(function() { $('#errorMessage').fadeOut(); }, 3000);")
         }
      })
   })
}
