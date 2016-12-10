library(shiny)
library(DBI)
library(RPostgreSQL)


# Define UI for application that draws a histogram
shinyUI(fluidPage(

  
  # Application title
  titlePanel("Control Otolitos"),

  # Sidebar with a slider input for the number of bins
  sidebarLayout(
      sidebarPanel(
      sliderInput("numotol", "Objetivo otolitos:",
                    min = 1, max = 50, value = 10),
      uiOutput("spps"),
      downloadButton("report", "Generar informe"),
      checkboxInput("pendientes", "Sólo Clases de tallas incompletas ", TRUE),
      HTML('<a href=https://tornerapps.shinyapps.io/principal/><button style="height:40px;width:150px" type="button" ><H4>Volver</H4></button></a>')
      
      
      ),

    # Show a plot of the generated distribution
    mainPanel(
      imageOutput("barras"),
      tableOutput("tablilla")
      
      
    )
  )
))
