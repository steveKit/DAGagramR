dagVisualizationServer <- function(id, toDataStorage, treatment, response, 
                          highlightedPathList, isTransportability,
                          dagDownloads, backdoorShow, effectModifierShow,
                          layout) {
   moduleServer(id, function(input, output, session) {
      ns <- session$ns
      # Create reactive values to store the graph and open path information
        reactiveGraph <- reactiveVal(NULL)
        causalPathList <- reactiveVal(NULL)
        showWarning <- reactiveVal(FALSE)
        
        firstGraphSimple <- reactive(BuildBaseGraph(toDataStorage$data, treatment(),
                                              response(), isTransportability()))
          
        observe({
          tempData <- toDataStorage$data
          effectModifiers <- FindEffectModifiers(tempData, response())
          temp <- toDataStorage$data %>%
            mutate(effectModifier = if_else(name %in% effectModifiers, TRUE, FALSE))
          
          toDataStorage$data <- temp
          
          firstGraph <- BuildBaseGraph(toDataStorage$data, treatment(),
                                           response(), isTransportability())
          
          dagDownloads$dag <- firstGraph
          
          dagDownloads$legend <- DAGLegend()
          
          # Find Open Causal Paths
          openPaths <- FindOpenPaths(toDataStorage$data, treatment(), response())
          causalPaths <- FindCausalPaths(openPaths)
          
          conditionedNodes <- toDataStorage$data %>%
            filter(conditioned)
          conditionedNodes<- unique(as.list(conditionedNodes$name))
          
          selectionBiasPaths <- FindSelectionBiasPaths( openPaths, conditionedNodes )
          
          causalPaths <- c(causalPaths, selectionBiasPaths)
          
          if(length(selectionBiasPaths) > 0){
            output$conditioningWarning <- renderUI({
              p("Warning: You are conditioning on a collider")
            })
          } else {
            output$conditioningWarning <- renderUI({})
          }
      
          # Graphs the open paths that lead into "x"
          fullEdgeDf <- data.frame()
          for (path in causalPaths) {
           edgeDf <- PathStringToDF(path)
            fullEdgeDf <- rbind(fullEdgeDf,edgeDf) %>% unique()
          }
          
          if (nrow(fullEdgeDf) > 0) {
            firstGraph <- AddOpenPathToGraph(firstGraph, fullEdgeDf)
          }
          
          unmeasuredNodes <- toDataStorage$data %>%
                              filter(unmeasured)
          
          if (any(fullEdgeDf$name %in% unmeasuredNodes$name) |
              any(fullEdgeDf$to %in% unmeasuredNodes$name)) {
            showWarning(TRUE)
          } else {
            showWarning(FALSE)
          }
      # ------------------------------------------------------------------------------
      # 
      #     if (effectModifierShow()) {
      #       graphWithEffectMods <- addEffectModifiersToGraph(firstGraph, effectModifiers)
      #       print("The effect Modifiers will be added")
      #     } else {
      #       print("TheEffectModifiersAreRemoved")
      #     }
      # ------------------------------------------------------------------------------
          
          
          # Store the graph and causal path in the reactive values
          simpleGraph <- firstGraphSimple()
          reactiveGraph(firstGraph)
          causalPathList(causalPaths)
          dagDownloads$backdoorDag <- firstGraph
          dagDownloads$dag <- simpleGraph
        })
        
        output$dagLegend <- renderGrViz({
          legendGraph <- DAGLegend()
          render_graph(legendGraph, layout = "kk")
        })
        
        
        observe({
          effectModifiers <- toDataStorage$data %>%
            filter(effectModifier)
          effectModifiers <- unique(as.list(effectModifiers$name))
          
          if (backdoorShow()){
            if(showWarning()){
              output$unmeasuredWarning <- renderUI({
                h6("*Orange Path cards contain an unmeasured node",
                   style = "color:var(--success); margin:5px;")
              })
            } else {
              output$unmeasuredWarning <- renderUI({})
            }
            
            if (effectModifierShow()){
              effectModifierGraph <- addEffectModifiersToGraph(reactiveGraph(),
                                                               effectModifiers)
              
              output$coloredDag <- renderGrViz({
                render_graph(
                  effectModifierGraph %>%
                    add_global_graph_attrs("rankdir", "LR", attr_type = "graph"),
                  layout = layout()
                )
              })
            } else {
              output$coloredDag <- renderGrViz({
                req(reactiveGraph())  # Ensure the graph is available
                render_graph(
                  reactiveGraph() %>%
                    add_global_graph_attrs("rankdir", "LR", attr_type = "graph"),
                  layout = layout()
                )
              })
            }
            
          } else {
            if (effectModifierShow()){
              print("Adding effect modifiers and displaying graph")
              effectModifierGraph <- addEffectModifiersToGraph(firstGraphSimple(),
                                                               effectModifiers)
              
              output$coloredDag <- renderGrViz({
                render_graph(
                  effectModifierGraph %>%
                    add_global_graph_attrs("rankdir", "LR", attr_type = "graph"),
                  layout = layout()
                )
              })
            } else {
              output$coloredDag <- renderGrViz({
                render_graph(
                  firstGraphSimple() %>%
                    add_global_graph_attrs("rankdir", "LR", attr_type = "graph"),
                  layout = layout())
              })
            }
          }
        })
        
        # Display cards for open paths going to treatment (<)
        observe({
          buttons <- lapply(seq_along(causalPathList()), function(i) {
            uniqueId <- paste0("viewPath", i)
            pathData <- PathStringToDF(causalPathList()[i])
            pathData <- unique(c(pathData$name, pathData$to))
            pathData <- toDataStorage$data %>%
              filter(name %in% pathData)
            
            # if (causalPathList()[i] %in% highlightedPathList()) {
            #   cardClasses <- c("highlighted")
            # } else {
            #   cardClasses <- c()
            # }
            
            if (any(pathData$unmeasured == TRUE)) {
              actionButton(inputId = ns(uniqueId), label = causalPathList()[[i]],
                           class = c("unmeasuredPath"))
            } else{
              actionButton(inputId = ns(uniqueId), label = causalPathList()[[i]],
                           class = c("measuredPath"))
            }
          })
          
          if(backdoorShow()){
            output$openPaths <- renderUI({
              lapply(buttons, function(btn){
                btn
              })
            })
          } else {
            output$openPaths <- renderUI({
              p("")
            })
          }
        })
        
        buttonList <- reactiveValues(values = c())
        
        observe({
          lapply(seq_along(causalPathList()), function(i) {
            # Makes sure observe event doesn't already exist for name
            if(!(i %in% buttonList$values)){
              buttonList$values <- c(buttonList$values, i)
      
              # Set up the observer for when view path button is pushed
              observeEvent(input[[paste0("viewPath", i)]], {
                # When Eye button is pushed do the following:
                shinyjs::toggleClass(id = ns(paste0("viewPath", i)), class = "highlighted", asis = TRUE)
                
                edgeDf <- PathStringToDF(causalPathList()[[i]])
                
                # 1. Remove or add path from highlightedPathList
                # based on if it's in the list
                if(causalPathList()[[i]] %in% highlightedPathList()) {
                  highlightedPathList(
                    highlightedPathList()[highlightedPathList() != causalPathList()[[i]]]
                  )
                  
                  # TODO make the card go back to normal
                } else {
                  highlightedPathList(c(highlightedPathList(), causalPathList()[[i]]))
                }
                
                # 2. basic graph - get rid of open paths already on graph
                tempGraph <- RemovePathFromGraph(reactiveGraph(), unique(edgeDf))
                tempGraph <- AddPathToGraph(tempGraph, unique(edgeDf))
                
                
                # 3. Add the highlightedPathList to graph
                highlightedEdgeDf <- data.frame(
                  name = character(),
                  to = character(),
                  stringsAsFactors = FALSE
                )
                for (path in highlightedPathList()) {
                  edgeDf <- PathStringToDF(path)
                  highlightedEdgeDf <- rbind(highlightedEdgeDf,edgeDf) %>%
                    unique()
                }
      
                if (nrow(highlightedEdgeDf) > 0) {
                  tempGraph <- AddOpenPathToGraph(tempGraph,
                                                  highlightedEdgeDf, 1)
                }
      
                # 4. Add open paths that aren't highlighted
                if (length(causalPathList() >= 1)) {
                  # Find the paths that aren't highlighted
                  causalEdgeDf <- data.frame()
                  for (path in causalPathList()) {
                    edgeDf <- PathStringToDF(path)
                    causalEdgeDf <- rbind(causalEdgeDf,edgeDf) %>% unique()
                  }
      
                  notHighlightedDf <- causalEdgeDf %>%
                    anti_join(highlightedEdgeDf,
                              by = join_by(name, to))
      
                  # If there are paths, graph them
                  if (nrow(notHighlightedDf) > 0) {
                    tempGraph <- AddOpenPathToGraph(tempGraph, notHighlightedDf)
                  }
                }
      
                # Save out graph into reactive element
                reactiveGraph(tempGraph)
              })
            }
          })
        })
   })
}
