library(shiny)
library(DBI)
library(RPostgreSQL)


# Define UI for application that draws a histogram
shinyUI(fluidPage(

  
  # Application title
  titlePanel("Control de Muestreo Biológico"),

  # Sidebar with a slider input for the number of bins
  sidebarLayout(
     sidebarPanel(
      uiOutput("spss"),
      htmlOutput("summary"),
      tableOutput("tablilla"),
      downloadButton("report", "Generar informe"),
      HTML('<a href=https://tornerapps.shinyapps.io/principal/><button style="height:40px;width:150px" type="button" ><H4>Volver</H4></button></a>')
      
    ),
    
    
    
    # Show a plot of the generated distribution
    mainPanel(
      plotOutput("distPlot"),
      plotOutput("lmPlot")
      
      
    )
  )
))
