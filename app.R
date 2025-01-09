# Core Shiny packages
library(shiny)
library(shinydashboard)
library(shinyjs)
library(shinyWidgets)
library(shinytest2)
library(bslib)

# Data visualization packages
library(tidyverse)
library(ggdag)
library(dagitty)

# Graph rendering packages
library(DiagrammeR)
library(DiagrammeRsvg)
library(rsvg)

# Source UI components
source("R/ui.R")
source("R/ui/appTheme.R")
source("R/ui/headerUI.R")
source("R/ui/sidebarUI.R")
source("R/ui/main_contentUI.R")
source("R/ui/downloadsUI.R")
source("R/ui/version_historyUI.R")
source("R/ui/effectModifierSwitchUI.R")
source("R/ui/welcomeModalUI.R")
# source("R/ui/displayNodesUI.R")
# source("R/ui/addNodeModalUI.R")

# Source server components
source("R/server.R")
source("R/welcomeModalServer.R")
source("R/addNodeFormServer.R")
source("R/ui/addNodeFormUI.R")
# source("R/displayNodesServer.R")

# Source modules
source("R/helpers.R")

source("displayNodes/ui.R")
source("displayNodes/server.R")
source("openBackDoorPathsDAG/ui.R")
source("openBackDoorPathsDAG/server.R")
source("nameModal/server.R")
source("RCode/server.R")
source("renameNodeForm/server.R")
source("renameNodeForm/ui.R")
source("editNodeModal/ui.R")
source("editNodeModal/server.R")

# Environment-based warning level
app_env <- Sys.getenv("R_ENV", "development")
warning_level <- if(app_env == "production") -1 else 1

# Set warning level
options(warn = warning_level)

# Compile UI
ui <- createUI(appTheme)

shinyApp(ui, server)