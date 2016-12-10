library(shiny)
library(DBI)
library(RPostgreSQL)
library(ggplot2)
library(maps)

shinyServer(function(input, output,session) {
  
  output$lance<-renderUI({
    drv<-dbDriver("PostgreSQL")
    con<-dbConnect(drv,dbname="vbhwjxcm",host="hard-plum.db.elephantsql.com",user="vbhwjxcm",
                   password="dNwTMDBQGUqF5lBbV7pxWccvLKrL7Z64")
    lances<-fetch(dbSendQuery(con,"select distinct lance from lances 
                            where camp='IEOR2016'
                            order by lance"),-1)
    
    dbDisconnect(con)
    
    selectInput("lance","Lance:", choices=lances)
  })
  
  
  
   datos.lance<-reactive({
     if(is.null(input$lance)){  
       c('Sin Datos')
     }else{
       drv<-dbDriver("PostgreSQL")
       con<-dbConnect(drv,dbname="vbhwjxcm",host="hard-plum.db.elephantsql.com",user="vbhwjxcm",
                      password="dNwTMDBQGUqF5lBbV7pxWccvLKrL7Z64")
       
       lance.query<-paste("SELECT
          to_char(fecha,'DD-MM-YYYY') as fecha,
          RADIAL,
          zona,
          ROUND((VIRPRF+FIRPRF)/2.0,2) AS profmedia,
          to_char((virtmp-firtmp)::interval,'HH24:mi') as tmparrastre,
          case when valido=true then 'VALIDO' else 'NULO' end as valido,
          firlat,
          firlon,
          firprf,
          to_char(firtmp,'HH24:mi') as firtmp,
          virlat,
          virlon,
          virprf,
          to_char(virtmp,'HH24:mi') as virtmp
          FROM lances,radiales
          where
          lances.radial=radiales.radialid and
          camp='IEOR2016'
          and lance=",input$lance,sep='')
       lance.data<-dbFetch(dbSendQuery(con,lance.query),-1)
       dbDisconnect(con)
       colnames(lance.data )<-c('Fecha','Radial','Zona','Prof. media','Dur. Arrastre','Válido',
                                'Lat. Firmes','Lon. Firmes','Prof. firmes','Hora firmes',
                                'Lat. virada','Lon. virada','Prof. virada','Hora virada')
        lance.data   
        }
       
       })
   
   output$tabla.res <- renderTable({
     if (is.null(input$lance)){
       c('Sin Datos')
       }else{
     datos<-datos.lance()
     datos[1:6]
       }
     })
   
   output$tabla.fir <- renderTable({
     if (is.null(input$lance)){
       c('Sin Datos')
     }else{
       datos<-datos.lance()
     datos[7:10]  
     }
       })
   
   output$tabla.vir <- renderTable({
     if (is.null(input$lance)){
       c('Sin Datos')
     }else{
       datos<-datos.lance()
     datos[11:14]
     }
       })
   

   
   output$mapa<-renderPlot({
     if (is.null(input$lance)){
       c('Sin Datos')
     }else{
       
     datos<-datos.lance()
     long=(datos[8]+datos[12])/2.0
     lat=(datos[7]+datos[11])/2.0
     map(database="world",regions=c("Spain","Portugal","Morocco"),
         ylim=c(35.5,37.5),xlim=c(-9,-5),col=gray(0.9), fill=TRUE)
     map.axes() 
     points(long, lat, pch="*",cex=3,col="red")
     abline(v=seq(-5,-9,-1),col=gray(0.5),lty=2)
     abline(h=seq(35,38,1),col=gray(0.5),lty=2)
     }
     })
   
   output$cabecero.res <- renderText({"<H2>Resumen del lance</H3>"})
   output$cabecero.fir <- renderText({"<H2>Firmes</H3>"})
   output$cabecero.vir <- renderText({"<H2>Virada</H3>"})
   output$cabecero.map <- renderText({"<H2>Situación</H3>"})   
   
   output$report <- downloadHandler(
     filename = "report.pdf",
     content = function(file) {
       # Copy the report file to a temporary directory before processing it, in
       # case we don't have write permissions to the current working dir (which
       # can happen when deployed).
       tempReport <- file.path(tempdir(), "report_template.Rmd")
       file.copy("report_template.Rmd", tempReport, overwrite = TRUE)
       
       # Set up parameters to pass to Rmd document
       params <- list(datos=datos.lance(),lance=input$lance)
       
       # Knit the document, passing in the `params` list, and eval it in a
       # child of the global environment (this isolates the code in the document
       # from the code in this app).
       rmarkdown::render(tempReport, output_file = file,
                         params = params,
                         envir = new.env(parent = globalenv())
       )
     })
   
})

