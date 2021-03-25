#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
#current_folder <- dirname(rstudioapi::getSourceEditorContext()$path)
#setwd(current_folder)

library(shiny)
library(scales)
library(ggplot2)
library(dplyr)
library(rsdmx)
library(zoo)
library(data.table)
library(pdfetch)
library(bdscale)
library(plotly)
library(tidyverse)
library(shinydashboard)
library(stringi)


# Define server logic required to draw a histogram
shinyServer(function(input, output){
    
    tickers = c('ANA.MC','FB','GENE','AAPL','MSFT','LUV','AMZN','AIV','BUD','HPQ','XOM','UAL')
    
    raw_data = pdfetch_YAHOO(tickers,
                             fields = c("open", "high", "low", "close", "adjclose", "volume"), 
                             from = as.Date("2013-01-01"),
                             to = as.Date("2016-07-01"), 
                             interval = "1d")
    
    
    df_complete = data.frame(date=index(raw_data), coredata(raw_data))
    
    news <- read.csv(file = 'Combined_News_DJIA.csv') 
    #news <- filter(news, Date > "2013-01-01")
    
    output$distPlot <- renderPlotly({
      
        company <- input$company
        positions <- stri_detect_fixed(colnames(df_complete), company)
        trues = which(positions %in% TRUE)
        minim = min(trues)
        maxim = max(trues)
        df <- df_complete[c(1, minim:maxim)]
        colnames(df) <- c("date", "open", "high", "low", "close", "adjclose", "volume")
        
        df <- filter(df, volume>0) 
        #df <- filter(df, volume < 500000)
        
        df$date <- as.Date(df$date, format = "%Y-%m-%d")
        
        df$volume <- df$volume/10000
        
        df$color[df$close - df$open >= 0] <- 'Positivo'
        
        df$color[df$close - df$open < 0] <- 'Negativo'
        
        df$crecimiento <- df$open - df$close
        cols <- c("Negativo" = "red", "Positivo" = "green")

        dff <- df[c(1,7,8,9)]
        dff$y <- df[,input$yPlot]
        dff <- data.table(dff)
        dff <- dff[date >= input$dateRange[1] & date <= input$dateRange[2]]
        
        g <- ggplot(data = dff) +
            geom_col(mapping = aes(x = date, y = y, fill = color)) +
            scale_fill_manual(values = cols, labels = c("Positivo",  "Negativo"), name = "Valor al cierre") +
            xlab("Fecha") +
            ylab("Valor del mercado") +
            ggtitle(input$company) +
            theme(plot.title = element_text(color="darkblue", size=15, face="bold"))+ 
            theme(axis.line = element_line(color = "darkblue", linetype = "solid"))
        if (input$Checkvolume == TRUE)
          g <- g + geom_line(aes(x = date, y = volume), color = "blue") 
        g <- ggplotly(g, tooltip = c('text'), dynamicTicks=TRUE) 
    })
    


    output$click1 <- renderInfoBox({
      d <- event_data("plotly_click")
      
      if (!is.null(d)){
        new1 <- filter(news, Date == d$x)$Top1
       
        box(
          title = "Primera noticia",
          new1,
          width = 12,
          solidHeader = TRUE,
          status = "primary",
          tableOutput("consumption")
        )
      }else{
        
        box(
          title = "Aqui se muestran las noticias mas destacadas de la fecha seleccionada",
          width = 12,
          solidHeader = TRUE,
          status = "primary",
          tableOutput("consumption")
          
        )
      }
    })
    output$click2 <- renderInfoBox({
      d <- event_data("plotly_click")
      
      if (!is.null(d) && !is.null(filter(news, Date == d$x)$Top2)){
        
        new2 <- filter(news, Date == d$x)$Top2
        
        box(
          title = "Segunda noticia",
          new2,
          width = 3,
          solidHeader = TRUE,
          status = "primary",
          tableOutput("consumption")
        )
      }else{
        
        box(
          title = "Segunda noticia",
          "No hay mas noticias registradas",
          width = 3,
          solidHeader = TRUE,
          status = "primary",
          tableOutput("consumption")
        )
      }
    })
    output$click3 <- renderInfoBox({
      d <- event_data("plotly_click")
      
      if (!is.null(d) && !is.null(filter(news, Date == d$x)$Top3)){
        
        new3 <- filter(news, Date == d$x)$Top3
        box(
          title = "Tercera noticia",
          new3,
          width = 3,
          solidHeader = TRUE,
          status = "primary",
          tableOutput("consumption")
        )
      }else{
        box(
          title = "Tercera noticia",
          "No hay mas noticias registradas",
          width = 3,
          solidHeader = TRUE,
          status = "primary",
          tableOutput("consumption")
        )
        
      }
    })
})
