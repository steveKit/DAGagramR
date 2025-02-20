# Core Shiny packages
library(shiny)
library(bslib)
library(shinydashboard)
library(shinyjs)
library(shinyWidgets)

# Bootstrap packages
library(shinyBS)
library(bsicons)

# Data visualization packages
library(tidyverse)
library(ggdag)
library(dagitty)

# Graph rendering packages
library(DiagrammeR)
library(DiagrammeRsvg)
library(rsvg)

# Testing packages
library(shinytest2)

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
source("R/ui/newNodeModalUI.R")

# Source server components
source("R/server.R")
source("R/welcomeModalServer.R")
source("R/nameModal.R")

# Source modules
source("R/modules/addNode/addNodeServer.R")
source("R/modules/addNode/addNodeUI.R")
source("R/modules/displayNodes/displayNodesServer.R")
source("R/modules/displayNodes/displayNodesUI.R")
source("R/modules/dagVisualization/dagVisualizationServer.R")
source("R/modules/dagVisualization/dagVisualizationUI.R")
source("R/modules/editNodeModal/editNodeModalServer.R")
source("R/modules/editNodeModal/editNodeModalUI.R")
source("R/modules/renameNodeForm/renameNodeFormServer.R")
source("R/modules/renameNodeForm/renameNodeFormUI.R")

# Source utils
source("R/utils/generateDAGCode.R")

## Source helpers
source("R/helpers.R")

##### TEMP SOURCES ######


# Environment-based warning level
app_env <- Sys.getenv("R_ENV", "development")
warning_level <- if(app_env == "production") -1 else 1

# Set warning level
options(warn = warning_level)

# Compile UI
ui <- createUI(appTheme)

shinyApp(ui, server)