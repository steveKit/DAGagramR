# --------------------------------- -
# FORM FUNCTIONS 
# --------------------------------- -

setFillColor <- "white"
setOutlineColor <- "#423f85"
setFontColor <- "black"

# For treatment and response
baseNodeFillColor <- "white"
baseNodeOutlineColor <- "black"
baseNodeFontColor <- "black"

conditionedFillColor <- "#D8EB79"
conditionedOutlineColor <- "#BDDD21"
conditionedFontColor <- "black"

unmeasuredNodeFillColor <- "lightgrey"
unmeasuredNodeOutlineColor <- "#767372"
unmeasuredNodeFontColor <- "#767372"


# Sets up '*' for mandatory fields
LabelMandatory <- function( label ) {
  i <- tagList(
      span("*", class = "MandatoryStar"),
      label
    )
  return(i)
}


# Checks that name follows the rules:
#    Not an empty value
#    No Special Characters
#    below 14 Characters
#    Isn't graph or node

CheckNameInput <- function( name ) {
  
  error_text <- ""
  
  # Makes sure there is a value
  name_not_null <- (!is.null(name) && name != "")
  
  if(!name_not_null){
    error_text <- "Node must have a name"
    return(list(isValid = FALSE, errorMessage = error_text))
  } else {
    # These words cause issues somewhere else in the code
    name_not_special <- (name != "node" && name != "graph" && name != "newNode")
    
    if(!name_not_special){
      error_text <- 'Name cannot be "node", "newNode", or "graph"'
    }
    
    # No spaces or special characters in the input
    no_space_special_char <- (
      str_length(name) == str_length(str_replace_all(name, " ", "")) &&
        !(grepl("[^A-Za-z0-9_ ]", name))
    )
    
    if(!no_space_special_char){
      error_text <- "Do not use spaces or special characters in name"
    }
    
    below_char <- str_length(name) <= 14
    
    if(!below_char){
      error_text <- "Name must be below 14 characters"
    }
  }
  
  
  text_filled <- ((
    name_not_null && name_not_special && no_space_special_char && below_char
  ))
  
  if(text_filled){
    error_text <- ""
  }
  
  return(list(isValid = text_filled, errorMessage = error_text))
}


# --------------------------------- -
# UPDATE DATA FORMATS 
# --------------------------------- -

# Converts form data to long format
ToDataLong <- function( toData ) {
  longDF <- toData %>%
    pivot_longer(cols = c(parents, children), names_to = "relation", values_to = "node") %>%
    unnest_longer(node) %>%
    mutate(relation = if_else(relation == "parents", "parent", "child"))
  
  to_df <- longDF %>%
    filter(relation == "child") %>%
    rename(to = node) %>%
    select(name, to)
  
  from_df <- longDF %>%
    filter(relation == "parent") %>%
    rename(to = name, name = node) %>%
    select(name, to)
  
  longDF <- bind_rows(to_df, from_df)
  
  return(longDF)
}


# Turns the toDataStorage data into a dag for analysis (Path finding)
DataToDag <- function( toData ) {
  dag <- toData %>%
    mutate(
      temp = to,
      to = name,
      name = temp
    ) %>%
    filter(!is.null(to)) %>%
    as_tidy_dagitty
  
  # Create the DAG
  # pull_dag flips the to and name (as fixed in the mutate)
  dag <- pull_dag(dag)
  
  return(dag)
}


# --------------------------------- -
# PATH FUNCTIONS 
# --------------------------------- -

# Returns a list of all open paths
FindOpenPaths <- function( toData, response, treatment ) {
    toDag <- DataToDag(toData)
    
    conditionedNodes <- toData %>%
      filter(conditioned)
    conditionedNodes <- unique(as.list(conditionedNodes$name))

    allPaths <- paths(toDag,
                      from = response,
                      to = treatment,
                      Z = conditionedNodes
                )
    
    openPaths <- allPaths$paths[allPaths$open]

    return(openPaths)
}


# From a path list filter to the paths going into x
FindCausalPaths <- function( pathList ) {
  causalPaths <- c()
  for (path in pathList) {
    # Finds the first character after a space to see if it is going to ("<") treatment ("x")
    tempSub <- sub("^.*?\\s+(.)", "\\1", path)
    if (substr(tempSub, 1, 1) == "<") {
      causalPaths <- append(causalPaths, path)
    }
  }
  
  return(causalPaths)
}


# From a path list filter to the paths caused by Selection Bias 
# (conditioning on a Collider)
FindSelectionBiasPaths <- function( pathList, conditionedList ) {
  if (length(conditionedList) > 0) {
    selectionBiasPaths <- c()
    for (path in pathList) {
      # Find the children of x
      tempSub <- sub("^.*?\\s+(.)", "\\1", path)
      if (substr(tempSub, 1, 1) != "<") {
        # Check if the path has a conditioned variable
        containsItem <- any(sapply(conditionedList, grepl, path))
        if (containsItem) {
          selectionBiasPaths <- c(selectionBiasPaths, path)
        }
      }
    }
    return(selectionBiasPaths)
  }
}



# Converts a path (string) to a data frame for graphing
PathStringToDF <- function( path ) {
  pathDF <- unlist(strsplit(path, " "))
  
  nodeList <- c()
  directionList <- c()
  
  # Gives us our nodes
  for (s in pathDF) {
    if (s != "<-" & s != "->") {
      nodeList <- append(nodeList, s)
    } else {
      directionList <- append(directionList, s)
    }
  }
  
  # Build the data frame
  columns <- c("name", "to")
  
  edgeDF <- data.frame(matrix(nrow = 0, ncol = length(columns)))
  colnames(edgeDF) <- columns
  
  i <- 1
  for (d in directionList) {
    if (d == "->") {
      edgeDF[nrow(edgeDF) + 1,] = c(nodeList[i], nodeList[i+1])
    } else {
      edgeDF[nrow(edgeDF) + 1,] = c(nodeList[i+1], nodeList[i])
    }
    i <- i + 1
  }
  
  return(edgeDF)
}

# --------------------------------- -
# GRAPHING FUNCTIONS
# --------------------------------- -

BuildBaseGraph <- function( toData, treatment, response, transportability = FALSE ) {
  if(transportability){
    baseList <- c(treatment, response, "Participation")
  } else {
    baseList <- c(treatment, response)
  }
  
  conditionedNodes <- toData %>%
    filter(conditioned)
  conditionedNodes <- unique(as.list(conditionedNodes$name))

  unmeasuredNodes <- toData %>%
    filter(unmeasured)
  unmeasuredNodes <- unique(as.list(unmeasuredNodes$name))
  
  coloredNodes <- c(conditionedNodes, unmeasuredNodes, baseList)
  
  # Create the base graph
  firstGraph <- create_graph() %>%
    add_nodes_from_df_cols(
      df = toData,
      columns = c("name")
    ) %>%
    add_edges_from_table(
      table = toData,
      from_col = name,
      to_col = to,
      from_to_map = label
    ) %>%
    select_nodes() %>%
    set_node_attrs_ws(node_attr = fixedsize, value = FALSE) %>%
    set_node_attrs_ws(node_attr = shape, value = "rectangle") %>%
    set_node_attrs_ws(node_attr = font, value = "Open Sans") %>%
    clear_selection() %>%
    mutate_node_attrs(base = if_else(label %in% baseList, TRUE, FALSE)) %>%
    select_nodes(conditions = base) %>%
    set_node_attrs_ws(node_attr = fillcolor, value = baseNodeFillColor) %>%
    set_node_attrs_ws(node_attr = color, value = baseNodeOutlineColor) %>%
    set_node_attrs_ws(node_attr = fontcolor, value = baseNodeFontColor) %>%
    clear_selection()

    

  # Color the conditioned Nodes if there are any
  if (length(conditionedNodes > 0)) {
    firstGraph <- firstGraph %>%
      mutate_node_attrs(conditioned = if_else(label %in% conditionedNodes, TRUE, FALSE)) %>%
      select_nodes(conditions = conditioned) %>%
      set_node_attrs_ws(node_attr = fillcolor, value = conditionedFillColor) %>%
      set_node_attrs_ws(node_attr = color, value = conditionedOutlineColor) %>%
      set_node_attrs_ws(node_attr = fontcolor, value = conditionedFontColor) %>%
      clear_selection()
  }
  
  if (length(unmeasuredNodes > 0)) {
    firstGraph <- firstGraph %>%
      mutate_node_attrs(unmeasured = if_else(label %in% unmeasuredNodes, TRUE, FALSE)) %>%
      select_nodes(conditions = unmeasured) %>%
      set_node_attrs_ws(node_attr = fillcolor, value = unmeasuredNodeFillColor) %>%
      set_node_attrs_ws(node_attr = color, value = unmeasuredNodeOutlineColor) %>%
      set_node_attrs_ws(node_attr = fontcolor, value = unmeasuredNodeFontColor) %>%
      clear_selection()
  }
  
  # If there are more than the conditioned and base nodes make the color white
  if (length(unique(toData$name)) != length(coloredNodes)) {
    firstGraph <- firstGraph %>%
      mutate_node_attrs(notBase = if_else(label %in% coloredNodes, FALSE, TRUE)) %>%
      select_nodes(conditions = notBase) %>%
      set_node_attrs_ws(node_attr = fillcolor, value = setFillColor) %>%
      set_node_attrs_ws(node_attr = color, value = setOutlineColor) %>%
      set_node_attrs_ws(node_attr = fontcolor, value = setFontColor) %>%
      clear_selection()
  }
  
  return(firstGraph)
}

# creates the legend 
DAGLegend <- function() {
  legendGraph <- create_graph() %>%
    add_node(label = "conditioned",
             node_aes = node_aes(
               fontcolor = conditionedFontColor,
               fillcolor = conditionedFillColor,
               color = conditionedOutlineColor,
               fixedsize = FALSE,
               shape = "rectangle"
             )) %>%
    add_node(label = "unmeasured",
             node_aes = node_aes(
               fontcolor = unmeasuredNodeFontColor,
               fillcolor = unmeasuredNodeFillColor,
               color = unmeasuredNodeOutlineColor,
               shape = "rectangle",
               fixedsize = FALSE
             ))
  
  return(legendGraph)
}


# Adds an open path (shown in RED)
AddOpenPathToGraph <- function( graph, pathDF, width = 0.3 ) {
  graph <- RemovePathFromGraph(graph, pathDF)
  graph <- AddPathToGraph(graph, pathDF)
  for (i in 1:nrow(pathDF)) {
    graph <- graph %>%
      add_edge(
        from = pathDF$name[i], to = pathDF$to[i],
        edge_aes = edge_aes(
          color = "red",
          arrowhead = "none",
          penwidth = width
        )
      )
  }
  
  return(graph)
}

# Helper Functions 
# Adds a basic edge to graph from a path Data Frame
AddPathToGraph <- function( graph, pathDF ) {
  for (i in 1:nrow(pathDF)) {
    graph <- graph %>%
      add_edge(
        from = pathDF$name[i], to = pathDF$to[i],
      )
  }
  
  return(graph)
}


# Removes all edges on a path from the graph
RemovePathFromGraph <- function( graph, pathDF ) {
  for (i in 1:nrow(pathDF)) {
    graph <- graph %>%
      delete_edge(
        from = pathDF$name[i], to = pathDF$to[i]
      )
  }
  
  return(graph)
}


# Images

convertImgToDataUrl <- function(path) {
  # Convert png to data encoded URL
  text_encoded_img <- base64enc::base64encode(path)
  data_url <- paste0("data:image/png;base64,", text_encoded_img)
  
  data_url
}