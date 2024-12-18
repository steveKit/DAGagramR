displayNodesServer <- function(input, output, session, toDataStorage, treatment,
                               response, highlightedPathList) {
  
  source("addNodeForm/server.R")
  source("renameNodeForm/server.R")
  source("renameNodeForm/ui.R")
  source("editNodeModal/ui.R")
  source("editNodeModal/server.R")
  
  ns <- session$ns
  observerInitialized <- reactiveVal(FALSE)
  
  cardList <- reactiveValues(values = c())
  
  library(shinyBS)  # For tooltips
  
library(bslib)  # For the tooltip function
library(bsicons)  # For Bootstrap icons

addModal <- function(newNS) { 
  modalDialog(
    fluidPage(
      tags$p("New Node", 
             style = "font-size: 2rem; font-weight: bold; margin-bottom: 20px; text-align: center;"),
      div(
        id = ns(newNS("newNode")),
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
  })  # Closing bracket for the second observe block
  
  # Edit Buttons
  observe({
    data <- toDataStorage$data
    
    lapply(unique(data$name), function(n) {
      # Initialize a unique edit mode for each button if not already initialized
      if (is.null(session$userData[[paste0("editMode", n)]])) {
        session$userData[[paste0("editMode", n)]] <- reactiveVal(FALSE)
      }
      
      # Create observer only if it does not exist
      if (is.null(session$userData[[paste0("editObserver", n)]])) {
        session$userData[[paste0("editObserver", n)]] <- TRUE
        
        session$onFlushed(function() {
          observeEvent(input[[paste0("editBtn", n)]], {
            # Perform actions for the specific button
            node_id <- paste0("editingNode", n)
            editNodeUI(ns("editNode"))
            
            editNodeServer(ns("editNode"), toDataStorage, treatment, response,
                           highlightedPathList, observerInitialized, n)
          }, ignoreInit = TRUE)
        }, once = TRUE)
      }
    })
  })  # Closing bracket for the third observe block
})
}# Closing bracket for displayNodesServer function
