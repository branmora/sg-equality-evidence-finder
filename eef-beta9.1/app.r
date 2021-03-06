#packages
library(markdown)
library(lubridate)
library(readxl)
library(openxlsx)
library(dplyr)
library(shiny)
library(shinyjs)
library(tidyr)
library(xts)
library(dygraphs)
library(zoo)
library(googleVis)
library(rmarkdown)
library(knitr)
library(shinydashboard)
library(DT)
onScots <- !require(RColorBrewer)
library(googlesheets)
library(purrr)
onScots <- !require(SPARQL) #package that doesn't work on Scots. onScots is a flag used to switch off functionality incompatible with Scots
library(shinycssloaders)
library(data.table)
options(spinner.color="#0080db",spinner.type=1)


# download data.table
table_recibidos <-fread('https://raw.githubusercontent.com/branmora/sg-equality-evidence-finder/master/files/datatest.csv')

#load helper scripts
source("EEF scripts/dygraph-extra-shiny.R",local=TRUE)
source("EEF scripts/helper_funcs.r",local=TRUE)

#load data (locally)
load("EEF/index.rData",environment())
load("EEF/graph_data.rData",environment())

#load ui/server scripts
source("EEF scripts/ui_pack.r",local=TRUE)
source("EEF scripts/ui_graphs.r",local=TRUE)
source("EEF scripts/server_pack.r",local=TRUE)
#source("EEF scripts/server_graphs (OLD).r",local=TRUE) #no longer needed?
source("EEF scripts/server_graphs.r",local=TRUE)

#user interface
ui <- fluidPage(
  tags$head(
    tags$meta(charset="utf-8"),
    tags$meta(name="viewport", content="width=device-width, initial-scale=1, shrink-to-fit=no"),
    HTML('<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.1.1/css/bootstrap.min.css" integrity="sha384-WskhaSGFgHYWDcbwN70/dfYBj47jz9qbsMId/iRN3ewGhXQFZCSftd1LZCfmhktB" crossorigin="anonymous">'),
    HTML('<link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Lato">'),
    HTML('<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">'),
    HTML('<link href="https://fonts.googleapis.com/css?family=Roboto:100,300,400,500,700,900,400italic" rel="stylesheet" type="text/css">'),
    HTML('<link rel="stylesheet" href="https://www.w3schools.com/w3css/4/w3.css">'),
    shinyjs::useShinyjs(),
    includeCSS("EEF scripts/tdstyles.css"),
    includeCSS("EEF scripts/dygraph.css"),
    includeCSS("EEF scripts/EEFextra.css"),
    tags$script(src = "javascript/dygraph-extra-modified-final.js"),
    tags$script(src="javascript/EEF.js"),
    tags$script(src = "javascript/jquery-ui-1-11-4.min.js"),
    tags$script('$(function(){$(".jui-tip").tooltip();});'),
    tags$style(type="text/css",
               ".shiny-output-error { visibility: hidden; }",
               ".shiny-output-error:before { visibility: hidden; }")
    
  ),
  
  ##UI components
  shinyjs::hidden(eefHelp()),
  eefHeader("equality"),
  # eefGrid("equality"),
  # shinyjs::hidden(eefContent("equality")),
  # eefHeaderImage(NS("equality","npf"),"National Performance Framework","EEF/Npfbackground.jpg",active=2,class="eef eef-main eef-summ"),
  npfText("eef eef-main eef-summ"),
  eefSection(NS("equality","NPF"),"Buscador de documentos",
             colour="eef-section-links",
             class="eef-section eef eef-main eef-summ",
             tabs = tabBox(
               width = 12,
               tabPanel("Documentos Recibidos", DT::dataTableOutput("mytable")),
               tabPanel("Documentos Emitidos", "second table"),
               tabPanel("Otros Documentos", "third table")
             )),
             # tabs=equalityButtons9(NS(NS("equality","NPF"),"section"),
             #                       title="Data Explorer",
             #                       active=c(TRUE,equalityCharacteristics%in%distinct(NPFdataIndex,Characteristic)$Characteristic),
             #                       buttonClass=c(paste0("eef-",allPolicyAreasID,collapse=" "),sapply(equalityCharacteristics,FUN=function(x) paste(character(0),policyCSS(filter(NPFdataIndex,Characteristic==x)$policy_area),collapse=" ")))),
             # content=uiOutputLoading(NS(NS("equality","NPF"),"panel"))),
  eefHeaderImage(NS("equality","publications"),"Publications & Data","EEF/parallax-publications2.jpg",active=2),
  br(),
  # eefSection(NS("equality","publications"),"Scottish Government Publications and Outputs", ----
  #            colour="eef-section-links",
  #            class=paste(c("eef-section","eef-main",policyCSS(unique(EEFpublishedIndex$policy_area))),collapse=" "),
  #            tabs=equalityButtons9(NS(NS("equality","publications"),"section"),
  #                                  title="Publications and Outputs",
  #                                  active=c(TRUE,equalityCharacteristicsID%in%filter(EEFpublishedIndex,policy_area=="Summary")$Characteristic),
  #                                  buttonClass=c(paste0("eef-",allPolicyAreasID,collapse=" "),sapply(equalityCharacteristicsID,FUN=function(x) paste(character(0),policyCSS(filter(EEFpublishedIndex,Characteristic==x)$policy_area),collapse=" ")))),#uiOutput("equality-publications-tabs"),
  #            content=uiOutputLoading(NS(NS("equality","publications"),"panel"))),
  # eefSection(NS("equality","external"),"External Publications and Research Organisations",
  #            colour="eef-section-links",
  #            class=paste(c("eef-section","eef-main",policyCSS(unique(EEFexternalIndex$policy_area))),collapse=" "),
  #            tabs=equalityButtons9(NS(NS("equality","external"),"section"),
  #                                  title="External Links",
  #                                  active=c(TRUE,equalityCharacteristicsID%in%filter(EEFexternalIndex,policy_area=="Summary")$Characteristic),
  #                                  buttonClass=c(paste0("eef-",allPolicyAreasID,collapse=" "),sapply(equalityCharacteristicsID,FUN=function(x) paste(character(0),policyCSS(filter(EEFexternalIndex,Characteristic==x)$policy_area),collapse=" ")))),#uiOutput("equality-publications-tabs"),
  #            content=uiOutputLoading(NS(NS("equality","external"),"panel"))),
  # eefSection(NS("equality","data"),"Data",
  #            colour="eef-section-links",
  #            class=paste(c("eef-section","eef-main",policyCSS(unique(EEFdataLinksIndex$policy_area))),collapse=" "),
  #            tabs=equalityButtons9(NS(NS("equality","data"),"section"),
  #                                  title="Data",
  #                                  active=c(TRUE,equalityCharacteristicsID%in%filter(EEFdataLinksIndex,policy_area=="Summary")$Characteristic),
  #                                  buttonClass=c(paste0("eef-",allPolicyAreasID,collapse=" "),sapply(equalityCharacteristicsID,FUN=function(x) paste(character(0),policyCSS(filter(EEFdataLinksIndex,Characteristic==x)$policy_area),collapse=" ")))),#uiOutput("equality-publications-tabs"),
  #            content=uiOutputLoading(NS(NS("equality","data"),"panel"))),
  # eefSection(NS("equality","collection"),"Data Collection Guidance",
  #            colour="eef-section-links",
  #            class=paste(c("eef-section","eef-main",policyCSS(allPolicyAreasID)),collapse=" "),
  #            tabs=equalityButtons9(NS(NS("equality","collection"),"section"),
  #                                  title="Data Collection Guidance",
  #                                  active=c(TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,FALSE,FALSE),
  #                                  buttonClass=sapply(c(TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,FALSE,FALSE),
  #                                                     function(x) if(x) paste0("eef-",allPolicyAreasID,collapse=" ") else "" )),
  #            #buttonClass=c(paste0("eef-",allPolicyAreasID,collapse=" "),sapply(equalityCharacteristicsID,FUN=function(x) paste(character(0),policyCSS(filter(EEFexternalIndex,Characteristic==x)$policy_area),collapse=" ")))),#uiOutput("equality-publications-tabs"),
  #            content=uiOutputLoading(NS(NS("equality","collection"),"panel"))), ----
  eefHeaderImage(NS("equality","contact"),"Contact","EEF/parallax-contact.jpg",active=3),
  br(),
  eefContactList(allPolicyAreasID[allPolicyAreasID!="summ"]),
  br(),br(),
  eefFooter(NS("equality","top")),
  HTML("<script src='https://cc.cdn.civiccomputing.com/8/cookieControl-8.x.min.js'></script>"),
  HTML("<script async src='https://www.googletagmanager.com/gtag/js?id=UA-128676670-1'></script>"),#main account
  #HTML("<script async src='https://www.googletagmanager.com/gtag/js?id=UA-128846881-1'></script>"),#test accout
  tags$script(src="javascript/eef-cookies.js")
  #tags$script("CookieControl.load( config );")
  
)

#shiny server
graphOptions[["incPov-11"]]$updateNPF <- TRUE 
server <- function(input,output,session) {
  
  
  #Table test
    
  table_recibidos$Descarga <- paste0("<a href='",table_recibidos$Descarga,">RStudio</a>' target='_blank'>","Descarga","</a>")
  
  output$mytable = DT::renderDataTable({
    datatable(table_recibidos, escape = FALSE,filter = 'top',
              options = list(language = list(url = '//cdn.datatables.net/plug-ins/1.10.11/i18n/Spanish.json')))
  })
  
  #count number of connections to the server (i.e. number of users visiting site) and store in a google sheet - This is done in the server and doesn't involve personal data so should be compliant with all privacy regs
  
  if(file.exists("gs_token.rds")) {
    gs_token <- readRDS("gs_token.rds")
    session$onSessionEnded(function() {
      gs_auth(gs_token)
      gs <- gs_title("Equality Evidence Finder",verbose=F)
      #gs_add_row(gs,input=data.frame(timeStamp=Sys.Date()),verbose=F)
      row <- month(Sys.Date())-3 + (year(Sys.Date())-2019)*12
      #gs_edit_cells(gs,input=gs_read(gs)$pageviews[row] + 1,anchor=paste0("B",row+1))
      gs_edit_cells(gs,input=data.frame(B=gs_read(gs)$pageviews[row] + 1,C=Sys.time()),anchor=paste0("B",row+1),col_names=FALSE) #experimental code for adding last updated time stame
    })
  }
  
  
  
  #links sections
  callModule(eefPublicationsSectionServer,"equality-publications",reactive({input$policyID}),updatePublications)
  callModule(eefPublicationsSectionServer,"equality-data",reactive({input$policyID}),updateData)
  callModule(eefPublicationsSectionServer,"equality-external",reactive({input$policyID}),updateExternal)
  callModule(eefPublicationsSectionServer,"equality-collection",reactive({input$policyID}),updateGuidance)
  callModule(eefPublicationsSectionServer,"equality-glossary",reactive({input$policyID}),updateGlossary)
  callModule(npfSectionServer,"equality-NPF")
  
  #summary sections
  lapply(unique(EEFindex$topicID),
         FUN=function(i) {
           callModule(eefSummarySectionServer,paste0("equality-",i),i,loadData)
         })
  
   
  #loadData contains all the data for graphs. Wrapped in a reactive expression to allow data to be update "live" from statistics.gov.scot. The reactive expression also means the data will only be loaded when it's needed (i.e. when a user clicks on the relevant section)
  loadData <- list()
  loadData[["npf"]] <- reactive({
    #if(identical(disableODP,TRUE)) return(graph[["npf"]])
    readData <- readNPFdata()
    if(is.null(readData)) graph[["npf"]] else readData
  })
  
  loadData[setdiff(names(graph),"npf")] <- lapply(setdiff(names(graph),"npf"),
                                        function(x) {
                                          reactive({
                                            # if(identical(disableODP,TRUE)) {
                                            #   graph[[x]]
                                            # } else 
                                            if(identical(graphOptions[[x]]$updateQuery,TRUE)) {
                                              EEFsparql(graph[[x]],graphOptions[[x]],x)
                                            } else if(identical(graphOptions[[x]]$updateNPF,TRUE)) {
                                             if(is.null(loadData[["npf"]]())) NULL else loadData[["npf"]]() %>% right_join(distinct(graph[[x]],Indicator,Characteristic),by=c("Indicator","Characteristic"))
                                            } else {
                                              graph[[x]]
                                            }
                                          })
                                        })
  
  lapply(names(graphOptions),
         FUN=function(x) {
           if(graphOptions[[x]]$graphType=="npfDataExplorer") callModule(npfServer3,x,loadData[[x]],graphOptions[[x]],filterChar=reactive({input[["equality-NPF-sectionEqualityID"]]}))
           if(graphOptions[[x]]$graphType=="timeSeries0") callModule(timeSeriesServer0,x,loadData[[x]],graphOptions[[x]],reactive(input$reload))
           if(graphOptions[[x]]$graphType=="timeSeries1") callModule(timeSeriesServer1,x,loadData[[x]],graphOptions[[x]],reactive(input$reload))
             if(graphOptions[[x]]$graphType=="timeSeries2") callModule(timeSeriesServer2,x,loadData[[x]],graphOptions[[x]],reactive(input$reload))
             if(graphOptions[[x]]$graphType=="lineChart0") callModule(lineChartServer0,x,loadData[[x]],graphOptions[[x]],reactive(input$reload))
             if(graphOptions[[x]]$graphType=="lineChart1") callModule(lineChartServer1,x,loadData[[x]],graphOptions[[x]],reactive(input$reload))
             if(graphOptions[[x]]$graphType=="lineChart2") callModule(lineChartServer2,x,loadData[[x]],graphOptions[[x]],reactive(input$reload))
             if(graphOptions[[x]]$graphType=="pieChart0") callModule(pieChartServer0,x,loadData[[x]],graphOptions[[x]],reactive(input$reload))
             if(graphOptions[[x]]$graphType=="pieChart1") callModule(pieChartServer1,x,loadData[[x]],graphOptions[[x]],reactive(input$reload))
             if(graphOptions[[x]]$graphType=="pieChart2") callModule(pieChartServer2,x,loadData[[x]],graphOptions[[x]],reactive(input$reload))
             if(graphOptions[[x]]$graphType=="barChart0") callModule(barChartServer0,x,loadData[[x]],graphOptions[[x]],reactive(input$reload))
             if(graphOptions[[x]]$graphType=="barChart1") callModule(barChartServer1,x,loadData[[x]],graphOptions[[x]],reactive(input$reload))
             if(graphOptions[[x]]$graphType=="barChart2") callModule(barChartServer2,x,loadData[[x]],graphOptions[[x]],reactive(input$reload))
             if(graphOptions[[x]]$graphType=="barChart3") callModule(barChartServer3,x,loadData[[x]],graphOptions[[x]],reactive(input$reload))
         })

}

#run app
shinyApp(ui=ui,server=server)
