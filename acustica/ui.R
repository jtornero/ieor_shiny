library(shiny)
library(DBI)

# Define UI for application that draws a histogram
shinyUI(fluidPage(

  
  # Application title
  titlePanel("Reparto de porcentajes de captura"),

  # Sidebar with a slider input for the number of bins
  sidebarLayout(
     sidebarPanel(
      uiOutput("lance"),
      htmlOutput("summary"),
      downloadButton("report", "Generar informe"),
      HTML('<a href=https://tornerapps.shinyapps.io/principal/><button style="height:40px;width:150px" type="button" ><H4>Volver</H4></button></a>')
      
    ),
 
    mainPanel(
      htmlOutput("cabecero1"),
      tableOutput("tableTodas"),
      htmlOutput("cabecero2"),
      tableOutput("tableSelec")
      
    )
  )
))
