#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shinyWidgets)
library(shiny)
library(scales)
library(ggplot2)
library(dplyr)
library(shiny)
library(rsdmx)
library(zoo)
library(data.table)
library(pdfetch)
library(bdscale)
library(plotly)
library(tidyverse)
library(shinydashboard)
library(stringi)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
    
    # Application title
    titlePanel("Stock Data"),
    includeCSS(path = "AdminLTE.css"),
    includeCSS(path = "shinydashboard.css"),
    
    # Sidebar with a slider input for number of bins
    fluidRow(
        column(5,
               dateRangeInput("dateRange","Introduzca el rango temporal deseado",
                              start=as.character("2013-01-01"),
                              end=as.character("2016-07-01"), 
                              min=as.character("2013-01-01"),
                              max=as.character("2016-07-01"),
                              format="yyyy-mm-dd"),
               checkboxInput('Checkvolume', label = "Habilitar el numero de transacciones - 1:10k"),
               offset=1
        ),
       
    ),
    
    fluidRow(
        column(7,
               # Show a plot of the generated distribution
               fluidRow(
                   dropdownButton(
                       tags$h3("List of Input"),
                       selectInput(inputId = "yPlot",
                                   label = "Campo a mostrar",
                                   selected = "open",
                                   c("Valor de apertura" = "open",
                                     "Valor al cierre" = "close",
                                     "Valor mas alto" = "high",
                                     "Valor mas bajo" =  "low",
                                     "Crecimiento diario" =  "crecimiento")),
                       selectInput(inputId = 'company', label = 'Empresa',
                                   selected = "FB",
                                   c('ANA.MC' = 'ANA.MC',
                                     'FB' = 'FB',
                                     'GENE' = 'GENE',
                                     'AAPL' = 'AAPL',
                                     'MSFT' = 'MSFT',
                                     'LUV' = 'LUV',
                                     'AMZN' = 'AMZN',
                                     'AIV' = 'AIV',
                                     'BUD' = 'BUD',
                                     'HPQ' = 'HPQ',
                                     'XOM' = 'XOM',
                                     'UAL' = 'UAL')),
                       circle = TRUE, status = "danger", icon = icon("gear"), width = "300px",
                       tooltip = tooltipOptions(title = "Click to see inputs !"))
                   
                   ),
               plotlyOutput("distPlot"),
               offset=1
               
        ),column(4, column(12,infoBoxOutput("click1"),
                 infoBoxOutput("click2"),
                 infoBoxOutput("click3"))
    )
)))
