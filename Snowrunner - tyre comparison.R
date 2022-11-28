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


# Connect to db ----------------------------------------------------------------
connection <-
odbc::dbConnect(odbc::odbc(),
  Driver = "SQL Server Native Client 11.0",
  Server = "tcp:turkey-sql.database.windows.net,1433",
  Database = "turkey",
  UID = "nate",
  PWD = "yadda123!"
)

# Query db ---------------------------------------------------------------------

# call all truck via stored procedure in db
SnowrunnerData <- 
odbc::dbGetQuery(connection,
                 "Rshiny.GetAllTrucks")

SnowrunnerData %<>%
  mutate(across(where(is.character), as.factor))
  

# UI ---------------------------------------------------------------------------
ui <- fluidPage(titlePanel("title panel"),
    
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
        # complete with visuals later
      )
    )
  )

# SERVER -----------------------------------------------------------------------
server <- function(input, output, session) {
  
  observeEvent(input$TruckName, {

      updateSelectInput(
        session,
        input = "TyreName",
        label = paste0("Choose tyre:", input$TruckName),
        choices = SnowrunnerData[SnowrunnerData$Truck_Name %in% input$TruckName,
                                 "Tyre", drop = TRUE]
        )
  })
  

  session$onSessionEnded(stopApp)
}


# RUN APP ----------------------------------------------------------------------
shinyApp(ui = ui, server = server)
