library(shiny)
library(shinyjs)
load("table.Rdata")
library(qvalue, lib.loc= .libPaths()[1])

shinyServer(function(input, output) {
 
      
  output$subTabs <- renderUI({
    tabsetPanel(id = "subTabPanel1", 
                tabPanel("Plot",plotOutput("qvaluePlot", height="1200px", width="1200px")%>% withSpinner(color="#c10b26") , downloadButton('downloadData.plot', 'Download Plot' )), tabPanel("Histogram", plotOutput("qvalueHist", height="1200px", width="1200px")%>% withSpinner(color="#c10b26"), downloadButton('downloadData.histogram', 'Download Histogram')), tabPanel("Summary", verbatimTextOutput("summary")%>% withSpinner(color="#c10b26"))    )
  })
  # Return the requested dataset
  
  # input$file1 will be NULL initially. After the user selects and uploads a 
  # file, it will be a data frame with 'name', 'size', 'type', and 'datapath' 
  # columns. The 'datapath' column will contain the local filenames where the 
  # data can be found.
  pi0Input <- reactive({
    switch(input$pi0method,
           "smoother" = "smoother",
           "bootstrap" = "bootstrap")
  })
  datasetInput <- reactive({
    inFile <- input$file
    if (is.null(inFile)) return()
    dataset <- read.csv(file.path("data", inFile), header=input$header, sep=input$sep)
    # generate an rnorm distribution and plot it
    dataset <-unlist(dataset,use.names=FALSE)
    qval <- qvalue(data.matrix(dataset),
                   pi0.method=pi0Input(), 
                   fdr.level=input$fdr, 
                   lambda=seq(from=input$lambda[1],
                              to=input$lambda[2],
                              by=input$step), 
                   smooth.df=input$sdf, 
                   smooth.log.pi0=input$pi0log,
                   trunc=input$trunc,
                   monotone=input$mono,
                   transf=input$transf,
                   adj=input$adj,
                   eps=input$eps,
                   pfdr=input$pfdr)
  })
  output$qvaluePlot <- renderPlot({
    out <- datasetInput()
    if (is.null(out)) return()
    plot(out)
  })
  output$qvalueHist <- renderPlot({
    out <- datasetInput()
    if (is.null(out)) return()
    hist(out)
  })
  # Generate a summary of the dataset
  output$summary <- renderPrint({
    out <- datasetInput()
    if (is.null(out)) return()
    summary(out)
  })
  output$summary2 <- renderPrint({
    paste0(help(qvalue))
  })
  output$downloadData <- downloadHandler(
    filename =c('qvalue_output.txt'),
    content = function(file) {
      qwrite(datasetInput(), file)
    }
  )
  output$help <- renderTable({
    if (is.null(table)) {return()}
    print(table)
  }, 'include.rownames' = FALSE
  , 'include.colnames' = TRUE
  , 'sanitize.text.function' = function(x){x}
  )
  # output$help <- renderUI({
  #addResourcePath("library", "usr/lib64/R/library") 
  #  getHelpURL=function() {
  #file=as.character(help(qvalue))
  #if (length(file) == 0) stop("No help file found")
  #path <- dirname(file)
  #dirpath <- dirname(path)
  #pkgname <- basename(dirpath)
  #"http://www.bioconductor.org/packages/release/bioc/manuals/qvalue/man/qvalue.pdf"
  #   "http://www.princeton.edu/~ajbass/qvalue_helpFiles/qvalue.html"
  # }
  # tags$iframe(#style="width: 100%; height: 100%; position: absolute; left: 0px; top: 0px; right: 0px; bottom: 0px; ",
  #   style="width: 100%; height: 600px;", # should be sized to contents but no idea how.
  #   seamless="TRUE",
  #   src=getHelpURL())
  # })
  output$about <- renderUI({
    wellPanel(
      p("This is a Shiny implementation of the qvalue R package, adapted from the app created by Andrew Bass. This tool allows to explore the FDR of the ExG associations that can be studied in CLIMGeno and GenoCLIM. The qvalue R package is by John Storey et al. and can be found at Bioconductor's repository:", a("qvalue package",     href="http://www.bioconductor.org/packages/release/bioc/html/qvalue.html")),
      p("In order to use this application:"),
      p("1. Choose the ExG association  of interest"),
      p("2. It is then possible to modify the settings that are used to estimate q-values with the various options on the side panel. See the 'Help' tab in the application or see the", a("user manual", href="http://www.bioconductor.org/packages/release/bioc/vignettes/qvalue/inst/doc/qvalue.pdf"), "for the qvalue package by John D. Storey and Andrew J. Bassfor explanations of these options."),
      p("3. To view useful visualizations of the results refer to the 'Figures' tab for plots produced by qvalue package. Allow enough time for calculations and plot redering. When you are finished with your analysis, you may click the 'Download Output' button to save your results.")
    )
  })
  output$ref <- renderUI({
    wellPanel(
      p("-", tags$b("Estimation Methodology:"), "Storey JD. (2002) A direct approach to false discovery rates. Journal of the Royal Statistical Society, Series B, 64: 479-498.", a("[PDF]", href="http://genomics.princeton.edu/storeylab//papers/directfdr.pdf")),
      p("-", tags$b("Genomics:"), "Storey JD and Tibshirani R. (2003) Statistical significance for genome-wide studies. Proceedings of the National Academy of Sciences, 100: 9440-9445.", a("[PDF]", href="http://genomics.princeton.edu/storeylab//papers/Storey_Tibs_PNAS_2003.pdf"), a("[Supplementary Information]", href="http://genomics.princeton.edu/storeylab/qvalue/results.html")),
      p("-", tags$b("Bayesian Connections:"), "Storey JD. (2003) The positive false discovery rate: A Bayesian interpretation and the q-value. Annals of Statistics, 31: 2013-2035.", a("[PDF]", href="http://genomics.princeton.edu/storeylab//papers/Storey_Annals_2003.pdf")),
      p("-", tags$b("Theory:"), "Storey JD, Taylor JE, and Siegmund D. (2004) Strong control, conservative point estimation, and simultaneous conservative consistency of false discovery rates: A unified approach. Journal of the Royal Statistical Society, Series B, 66: 187-205.", a("[PDF]", href="http://genomics.princeton.edu/storeylab//papers/623.pdf")), 
      
      div(tags$a(img(src='shiny.png',  height="100px"),href="https://shiny.rstudio.com/"),
          tags$a(img(src='rstudio.png',  height="100px"),href="https://www.rstudio.com/"),
          tags$a(img(src='bioconductor.png',  height="100px"),href="https://www.bioconductor.org/"),
          tags$a(img(src='1001.png',  height="100px"),href="http://1001genomes.org/"),  align="middle", style="text-align: center;"),
      
      h3(''),
      h3(''),
      
      tags$a(div(img(src='climtools.png',  align="middle"), style="text-align: center;"), href="http://www.personal.psu.edu/sma3/CLIMtools.html"),
      
      tags$a(div(img(src='climtools logo.png',  align="middle"), style="text-align: center;"), href="http://www.personal.psu.edu/sma3/CLIMtools.html"),
      tags$a(div(img(src='github.png'), style="text-align: center;"), href="https://github.com/CLIMtools/FDRCLIM"),
      
      h3(''),
      tags$a(div(img(src='assmann_lab.png'), style="text-align: center;"), href="http://www.personal.psu.edu/sma3/index.html")
      
      
      
      )
  })
  output$downloadData.plot <- downloadHandler(
    filename <- function() {
      paste('plot', Sys.Date(),'.pdf',sep='') },
    content <- function(file) {
      pdf(file, width=10, height=10)
      top6.plot <- plot(datasetInput())
      print(top6.plot)
      dev.off()},
    contentType = 'image/pdf'
  )    
  output$downloadData.histogram <- downloadHandler(
    filename <- function() {
      paste('histogram', Sys.Date(),'.pdf',sep='') },
    content <- function(file) {
      pdf(file, width=10, height=10)
      top6.hist <- hist(datasetInput())
      print(top6.hist)
      dev.off()},
    contentType = 'image/pdf')
 
})
      
      
