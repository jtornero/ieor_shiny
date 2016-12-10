library(shiny)
library(DBI)
library(RPostgreSQL)
library(ggplot2)

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
  
  todas.especies<-reactive({
    if(is.null(input$lance)){
      data.frame(c('Sin Datos'))
    }else{
    drv<-dbDriver("PostgreSQL")
    con<-dbConnect(drv,dbname="vbhwjxcm",host="hard-plum.db.elephantsql.com",user="vbhwjxcm",
                   password="dNwTMDBQGUqF5lBbV7pxWccvLKrL7Z64")
    
    todas.query<-paste(
    "WITH capturas AS (
      
      SELECT distinct
      fauna_final.lance,
      fauna_final.espcod as espcod,
      especies.alfa3 as alfa3,
      especies.ncien as ncien,
      fauna_final.ptotal as peso,
      sum(fauna_final.ntotal) as numero,
      case
      when fauna_final.espcod in
      ('10156','10152','10414','10641','10642','10522','10415','10416')
      then 'X'
      else ' '
      end  as eval
      FROM 
      fauna_final,especies,lances
      WHERE 
      fauna_final.espcod=especies.espcod
      and fauna_final.camp=lances.camp 
      and fauna_final.barcod=lances.barcod 
      and fauna_final.lance=lances.lance
      and fauna_final.camp='IEOR2016' 
      and fauna_final.lance=",input$lance,"
      GROUP BY
      fauna_final.lance,
      fauna_final.espcod,
      especies.alfa3,
      especies.ncien,peso,eval)
    
      select
      lance,
      espcod,
      alfa3,
      ncien,
      peso,
      numero,
      round(numero*100/sum(numero) over (partition by lance),2) as porcentaje,
      eval
      from capturas
      group by lance,espcod,alfa3,ncien,peso,numero,eval
      order by porcentaje desc",sep='')
    
    todas.data<-dbFetch(dbSendQuery(con,todas.query),-1)
    dbDisconnect(con)
    
    
    todas.data
    }

     
    })
  
  

 
  selec.especies<-reactive({
  if(is.null(input$lance)){  
    data.frame(c('Sin Datos'))
  }else{
  drv<-dbDriver("PostgreSQL")
  con<-dbConnect(drv,dbname="vbhwjxcm",host="hard-plum.db.elephantsql.com",user="vbhwjxcm",
                   password="dNwTMDBQGUqF5lBbV7pxWccvLKrL7Z64")
  
  selec.query<-paste(
    "WITH capturas AS (
    
    SELECT distinct
    fauna_final.lance,
    fauna_final.espcod as espcod,
    especies.alfa3 as alfa3,
    especies.ncien as ncien,
    fauna_final.ptotal as peso,
    sum(fauna_final.ntotal) as numero
    
    FROM 
    fauna_final,especies,lances
    WHERE 
    fauna_final.espcod in ('10156','10152','10414','10641','10642','10522','10415','10416')
    and fauna_final.espcod=especies.espcod
    and fauna_final.camp=lances.camp
    and fauna_final.barcod=lances.barcod
    and fauna_final.lance=lances.lance
    and fauna_final.camp='IEOR2016'
    and fauna_final.lance=",input$lance,"
    GROUP BY
    fauna_final.lance,fauna_final.espcod,especies.alfa3,especies.ncien,peso)
    
    select
    lance,
    espcod,
    alfa3,
    ncien,
    peso,
    numero,
    round(numero*100/sum(numero) over (partition by lance),2) as porcentaje
    from capturas
    group by lance,espcod,alfa3,ncien,peso,numero
    order by porcentaje desc",sep='')
    
  
  selec.data<-dbFetch(dbSendQuery(con,selec.query),-1)
  dbDisconnect(con)
  selec.data
  }
  
  })
  

  
   sumario.lance<-reactive({
     if(is.null(input$lance)){  
       c('Sin Datos')
     }else{
       drv<-dbDriver("PostgreSQL")
       con<-dbConnect(drv,dbname="vbhwjxcm",host="hard-plum.db.elephantsql.com",user="vbhwjxcm",
                      password="dNwTMDBQGUqF5lBbV7pxWccvLKrL7Z64")
       
       lance.query<-paste("SELECT

          RADIAL,
          zona,
          ROUND((VIRPRF+FIRPRF)/2.0,2) AS profmedia,
          firprf||'-'||virprf as rangoprofs,
          to_char((virtmp-firtmp)::interval,'HH24:mi') as tmparrastre
          

FROM lances,radiales
where
lances.radial=radiales.radialid and
camp='IEOR2016'
and lance=",input$lance,sep='')
       lance.data<-dbFetch(dbSendQuery(con,lance.query),-1)
       dbDisconnect(con)
       
       resumen.lance<-sprintf("<b>Radial:</b> %s - %s<br>
          <b>Rango profs.:</b> %s m<br>
          <b>Prof. media:</b> %s m<br>
          <b>Tiempo arrastre:</b> %s<br>",
          lance.data$radial,
          lance.data$zona,
          lance.data$rangoprofs,
          lance.data$profmedia,
          lance.data$tmparrastre)
}
       
       })
   
   output$tableTodas <- renderTable({todas.especies()})
   output$tableSelec<-renderTable({selec.especies()})
   output$summary<-renderText({sumario.lance()})
   output$cabecero1 <- renderText({"<H2>Todas las especies</H2>"})
   output$cabecero2 <- renderText({"<H2>Especies evaluacion</H2>"})   
   output$report <- downloadHandler(
     filename = "report.pdf",
     content = function(file) {
       # Copy the report file to a temporary directory before processing it, in
       # case we don't have write permissions to the current working dir (which
       # can happen when deployed).
       tempReport <- file.path(tempdir(), "report_template.Rmd")
       file.copy("report_template.Rmd", tempReport, overwrite = TRUE)
       
       # Set up parameters to pass to Rmd document
       params <- list(lance=input$lance,sumario=sumario.lance(),todas=todas.especies(),
                      seleccionadas=selec.especies())
       
       # Knit the document, passing in the `params` list, and eval it in a
       # child of the global environment (this isolates the code in the document
       # from the code in this app).
       rmarkdown::render(tempReport, output_file = file,
                         params = params,
                         envir = new.env(parent = globalenv())
       )
     })
   
})

