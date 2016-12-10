library(shiny)
library(DBI)

# Define UI for application that draws a histogram
shinyUI(fluidPage(

  
  # Application title
  titlePanel("Lance de pesca"),

  # Sidebar with a slider input for the number of bins
  sidebarLayout(
     sidebarPanel(
      uiOutput("lance"),
      downloadButton("report", "Generar informe"),
      HTML('<a href=https://tornerapps.shinyapps.io/principal/><button style="height:40px;width:150px" type="button" ><H4>Volver</H4></button></a>')
      
    ),
 
    mainPanel(
      htmlOutput("cabecero.res"),
      tableOutput("tabla.res"),
      htmlOutput("cabecero.fir"),
      tableOutput("tabla.fir"),
      htmlOutput("cabecero.vir"),
      tableOutput("tabla.vir"),
      htmlOutput("cabecero.map"),
      plotOutput("mapa")
      
    )
  )
))
