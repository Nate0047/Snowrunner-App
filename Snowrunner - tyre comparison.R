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
#   Driver = "SQL Server Native Client 11.0",
#   Server = "tcp:turkey-sql.database.windows.net,1433",
#   Database = "turkey",
#   UID = "nate",
#   PWD = "yadda123!"
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
        
        # truck selector
        selectizeInput(
          inputId = "TruckName",
          label = "Truck:",
          choices = SnowrunnerData$Truck_Name
        ),
      
        # tyre selector
        selectInput(
          inputId = "TyreName",
          label = "Tyre:",
          choices = NULL,
          multiple = TRUE
        )
        
      ),
      
      mainPanel(
         plotOutput("tyrePlot")
      )
    )
  )

# SERVER -----------------------------------------------------------------------
server <- function(input, output, session) {
  
  observeEvent(input$TruckName, {

      # updating tyre selection
      updateSelectInput(
        session,
        input = "TyreName",
        label = paste0("Choose tyre:", input$TruckName),
        choices = SnowrunnerData[SnowrunnerData$Truck_Name %in% input$TruckName,
                                 "Tyre", drop = TRUE]
        )
  })
    
      # reactive filtering of dataset for plotting
      refineTyre <- reactive({
        SnowrunnerData %>%
          filter(.$Truck_Name %in% input$TruckName) %>%
          filter(.$Tyre %in% input$TyreName)
      })
      
      # plotting dataset
      output$tyrePlot <- renderPlot({
        ggplot(refineTyre(), aes(x = Tyre, y = Tyre_Coefficient, fill = Tyre_Type)) +
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
