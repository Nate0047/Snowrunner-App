#
# SNOWRUNNER TYRE COMPARISON APP
#

# set lib path
.libPaths("C:/R library")

# install packages
if(!require("shiny")) {install.packages("shiny")}
library(shiny)
if(!require("shinythemes")) {install.packages("shinythemes")}
library(shinythemes)
if(!require("tidyverse")) {install.packages("tidyverse")}
library(tidyverse)
library(magrittr)
if(!require("ggplot2")) {install.packages("ggplot2")}
library(ggplot2)
if(!require("jsonlite")) {install.packages("jsonlite")}
library(jsonlite)
if(!require("odbc")) {install.packages("odbc")}
library(odbc)

# colour palette
cbPalette <- c("#999999", "#C4A484", "#411900", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

# # Connect to db ----------------------------------------------------------------
# connection <-
# odbc::dbConnect(odbc::odbc(),
#*
# )
# 
# # Query db ---------------------------------------------------------------------
# 
# # call all truck via stored procedure in db
# SnowrunnerData <- 
# odbc::dbGetQuery(connection,
#                  "Rshiny.GetAllTrucks")
# 
# SnowrunnerData %<>%
#   mutate(across(where(is.character), as.factor))

# for when DB doesnt work:
# write.csv(SnowrunnerData, "dbBackup.csv")
SnowrunnerData <- read.csv("dbBackup.csv")

# UI ---------------------------------------------------------------------------
ui <- fluidPage(titlePanel("Snowrunner Tyre Comparison App"),
    
    sidebarLayout(
      sidebarPanel(
        
        # truck selector1
        selectizeInput(
          inputId = "TruckName1",
          label = "Truck:",
          choices = SnowrunnerData$Truck_Name
        ),
      
        # tyre selector1
        selectInput(
          inputId = "TyreName1",
          label = "Tyre:",
          choices = NULL,
          multiple = TRUE
        ),
        
        # truck selector2
        selectizeInput(
          inputId = "TruckName2",
          label = "Truck:",
          choices = SnowrunnerData$Truck_Name
        ),
        
        # tyre selector2
        selectInput(
          inputId = "TyreName2",
          label = "Tyre:",
          choices = NULL,
          multiple = TRUE
        )
      ),
      
      mainPanel(
        plotOutput("tyrePlot1")
      )
    )
  )

# SERVER -----------------------------------------------------------------------
server <- function(input, output, session) {
  
  observeEvent(input$TruckName1, {

      # updating tyre selection 1
      updateSelectInput(
        session,
        input = "TyreName1",
        label = paste0("Choose tyre:", input$TruckName1),
        choices = SnowrunnerData[SnowrunnerData$Truck_Name %in% input$TruckName1,
                                 "Tyre", drop = TRUE]
      )
  })
    
  observeEvent(input$TruckName2, {
      # updating tyre selection 2
      updateSelectInput(
        session,
        input = "TyreName2",
        label = paste0("Choose tyre:", input$TruckName2),
        choices = SnowrunnerData[SnowrunnerData$Truck_Name %in% input$TruckName2,
                               "Tyre", drop = TRUE]
      )
  })
    
      # reactive filtering of dataset for plotting
      refineTyre1 <- reactive({
        SnowrunnerData %>%
          filter(.$Truck_Name %in% input$TruckName1) %>%
          filter(.$Tyre %in% input$TyreName1)
      })
      
      # plotting dataset
      output$tyrePlot1 <- renderPlot({
        ggplot(refineTyre1(), aes(x = Tyre, y = Tyre_Coefficient, fill = Tyre_Type)) +
          geom_bar(stat = "identity", position = "dodge") +
          scale_fill_manual(values = cbPalette) +
          ggtitle("Truck Tyre Comparison Chart") +
          labs(x = "Selected Tyre(s)", y = "Tyre Coefficient") +
          guides(fill = guide_legend(title = "Tyre Role"))
      })
      
      # reactive filtering of dataset for plotting
      refineTyre2 <- reactive({
        SnowrunnerData %>%
          filter(.$Truck_Name %in% input$TruckName2) %>%
          filter(.$Tyre %in% input$TyreName2)
      })
      
      # plotting dataset
      output$tyrePlot2 <- renderPlot({
        ggplot(refineTyre2(), aes(x = Tyre, y = Tyre_Coefficient, fill = Tyre_Type)) +
          geom_bar(stat = "identity", position = "dodge") +
          scale_fill_manual(values = cbPalette) +
          ggtitle("Truck Tyre Comparison Chart") +
          labs(x = "Selected Tyre(s)", y = "Tyre Coefficient") +
          guides(fill = guide_legend(title = "Tyre Role"))
      })
  
  session$onSessionEnded(stopApp)
}


# RUN APP ----------------------------------------------------------------------
shinyApp(ui = ui, server = server)
