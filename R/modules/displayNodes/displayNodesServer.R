displayNodesServer <- function(id, toDataStorage, treatment, response, highlightedPathList) {
   moduleServer(id, function(input, output, session) {
      ns <- session$ns
      
      observerInitialized <- reactiveVal(FALSE)
      
      cardList <- reactiveValues(values = c())
      
      addModal <- function(modalId) {
         
         modalDialog(
            fluidPage(
               tags$p("New Node",
                      style = "font-size: 2rem; font-weight: bold; margin-bottom: 20px; text-align: center;"),
               div(
                  id = ns(modalId("newNode")),
                  fluidRow(
                     div(
                        class = "label-container",
                        style = "display: flex; align-items: center; gap: 5px;", # Align label and tooltip inline
   
                        # "Name" Label
                        h5(LabelMandatory("Name"), style = "margin: 0;"),
   
                        # Tooltip beside the Name label
                        tooltip(
                           bsicons::bs_icon("info-circle-fill", title = "Name Rules"),
                           "Node names can be up to 14 characters, no spaces, and no special characters."
                        )
                     )
                  ),
                  textInput(ns(modalId("name")), NULL, ""),
                  uiOutput(ns(modalId("errorMessage"))),
                  radioButtons(ns(modalId("unmeasured")), tags$h5("Type"),
                               c("Measured" = "measured",
                                 "Unmeasured" = "unmeasured"
                               )),
                  fluidRow(
                     h5(LabelMandatory("Connections")),
                     column(6,
                            uiOutput(ns(modalId("checkboxGroupTo")))
                     ),
                     column(6,
                            uiOutput(ns(modalId("checkboxGroupFrom")))
                     )
                  ),
                  br(), br(),
                  uiOutput(ns(modalId("errorText"))),
                  uiOutput(ns(modalId("errorMessage2")))
               )
            ),
            footer = tagList(
               modalButton("Cancel"),
               actionButton(ns(modalId("add_node")), "Add Node", class = "btn-primary")
            )
         )
      }
      
      # addModal <- function(ns) {
      #    modalDialog(
      #       newNodeModalUI(ns),
      #       footer = tagList(
      #          modalButton("Cancel"),
      #          actionButton(ns("add_node"), "Add Node", class = "btn-primary")
      #       )
      #    )
      # }
      
      addNodeServer("newNode", toDataStorage,
                    treatment, response, highlightedPathList)
      
      renameNodesServer("renameNodes", toDataStorage,
                        treatment, response, highlightedPathList, observerInitialized)
      
      # Add Node Button
      observeEvent(input$newNode, {
         ns <- NS("newNode")
         showModal(addModal(ns))
      })
      
      # Rename Node Button
      observeEvent(input$renameNodes, {
         renameNodeUI(ns("renameNodes"))
      })
      
      # Conditioned Layout
      observe({
         # Select all node names from toDataStorage
         # Sort then display on Base, measured, unmeasured
         displayData <- toDataStorage$data %>%
            select(-c(to)) %>%
            unique() %>%
            arrange(desc(base), name)
         
         output$nodeBoxes <- renderUI({
            apply(displayData, 1, function(row) {
               fluidRow(
                  style = "width: 100%; padding-left: 0;",  # Remove margin-left for consistent alignment
                  if (row["base"]) {
                     div(
                        style = "display: inline-flex; align-items: center; gap: 5px;",  # Align buttons side by side
                        circleButton(
                           ns(paste0("editBtn", row["name"])),
                           icon = icon("pencil"),
                           size = "xs",
                           class = "editButton"
                        ),
                        actionButton(
                           ns(row["name"]),
                           row["name"],
                           class = "baseNode",
                           style = "display: inline-block; width: 150px; height: 40px; text-align: center; padding: 0; font-size: 14px; line-height: 40px;"  # Fixed size, centered text, no padding, and consistent line-height
                        )
                     )
                  } else if (row["unmeasured"]) {
                     div(
                        style = "display: inline-flex; align-items: center; gap: 5px;",  # Align buttons side by side
                        circleButton(
                           ns(paste0("editBtn", row["name"])),
                           icon = icon("pencil"),
                           size = "xs",
                           class = "editButton"
                        ),
                        actionButton(
                           ns(row["name"]),
                           row["name"],
                           class = "unmeasuredNode",
                           style = "display: inline-block; width: 150px; height: 40px; text-align: center; padding: 0; font-size: 14px; line-height: 40px;"  # Fixed size, centered text, no padding, and consistent line-height
                        )
                     )
                  } else {
                     nodeState <- displayData %>%
                        filter(name == row["name"]) %>%
                        select(name, conditioned) %>%
                        unique()
                     
                     if (nodeState$conditioned) {
                        classList <- c("measuredNode", "conditioned")
                     } else {
                        classList <- c("measuredNode")
                     }
                     
                     div(
                        style = "display: inline-flex; align-items: center; gap: 5px;",  # Align buttons side by side
                        circleButton(
                           ns(paste0("editBtn", row["name"])),
                           icon = icon("pencil"),
                           size = "xs",
                           class = "editButton"
                        ),
                        actionButton(
                           ns(row["name"]),
                           row["name"],
                           class = classList,
                           style = "display: inline-block; width: 150px; height: 40px; text-align: center; padding: 0; font-size: 14px; line-height: 40px;"  # Fixed size, centered text, no padding, and consistent line-height
                        )
                     )
                  }
               )
            })
         })
         
         # Observe each node for specific actions
         observe({
            displayData <- toDataStorage$data %>%
               select(-c(to)) %>%
               unique() %>%
               arrange(desc(base), name)
            
            # Only create observe events for unmeasured and not base data
            displayDataFiltered <- displayData %>%
               filter(!base & !unmeasured)
            
            # Create observe Events
            lapply(displayDataFiltered$name, function(i) {
               if (!(i %in% cardList$values)) {
                  cardList$values <- c(cardList$values, i)
                  
                  # Set up the observer for when view path button is pushed
                  observeEvent(input[[i]], {
                     CanCondition <- toDataStorage$data %>%
                        filter(unmeasured == FALSE)
                     # When node button is pushed do the following:
                     if (i %in% CanCondition$name) {
                        temp <- toDataStorage$data %>%
                           mutate(
                              conditioned = ifelse(name == i, !conditioned, conditioned)
                           )
                        
                        toDataStorage$data <- temp
                     }
                  })
               }
            })
         })
         
      })
   })
}