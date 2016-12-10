
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

shinyUI(fluidPage(

  # Application title
  titlePanel("Datos de campaña"),

  flowLayout(
      HTML('<a href=https://tornerapps.shinyapps.io/lances/><button style="height:200px;width:200px" type="button" ><H2>Lances</H4></button></a>'),
      HTML('<a href=https://tornerapps.shinyapps.io/control_bio/><button style="height:200px;width:200px" type="button" ><H2>Control Biológicos</H4></button></a>'),
      HTML('<a href=https://tornerapps.shinyapps.io/control_otolitos/><button style="height:200px;width:200px" type="button"><H2>Control de otolitos</H4></button></a>'),
      HTML('<a href=https://tornerapps.shinyapps.io/acustica/><button style="height:200px;width:200px" type="button"><H2>Reparto porcentajes captura<br>(Acústica)</H4></button></a>')
    
    ),
    mainPanel(
    )
  )
)
