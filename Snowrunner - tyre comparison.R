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

connection <-
odbc::dbConnect(odbc::odbc(),
  Driver = "SQL Server Native Client 11.0",
  Server = "tcp:turkey-sql.database.windows.net,1433",
  Database = "turkey",
  UID = "nate",
  PWD = "yadda123!"
)

odbc::dbGetQuery(connection, "select * from Truck")

# UI ---------------------------------------------------------------------------
ui <- shinyUI(
  
  fluidPage(
  
  # title panel
  titlePanel("Snowrunner tyre comparison App"),
  
  # row with a sidebar
  sidebarLayout(
           
    # sidebar input
    sidebarPanel(
      selectInput("Trucks", "Select truck:", choices = testdata$Truck),
           hr(),
           helpText("choose your flippin' truck mate!"))
  ),
  
  # main panel for visual
  mainPanel(
    plotOutput("truck-tyre-plot")
    )
  )
)

# SERVER -----------------------------------------------------------------------
server <- shinyServer(function(input, output) {
  
  # generate visual for main panel plot
  output$truck-tyre-plot <- renderPlot({
  
    # render visual
    # ???
})


# RUN APP ----------------------------------------------------------------------
shinyApp(ui = ui, server = server)
