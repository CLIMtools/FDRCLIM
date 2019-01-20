library(shiny)
library(qvalue, lib.loc= .libPaths()[1])
library(shiny)
library(shinythemes)
library(shinyjs)
library(markdown)
library(DT)
library(shinyjqui)###need to upload package to server
library(shinycssloaders)
options(shiny.maxRequestSize=300*1024^2)

files <- list.files("data")

shinyUI(fluidPage(
  tags$head(
    tags$head(includeScript("google-analytics.js")),
    tags$link(rel="stylesheet", type="text/css",href="style.css"),
    tags$script(type="text/javascript", src = "md5.js"),
    tags$script('!function(d,s,id){var js,fjs=d.getElementsByTagName(s)    [0],p=/^http:/.test(d.location)?\'http\':\'https\';if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src=p+"://platform.twitter.com/widgets.js";fjs.parentNode.insertBefore(js,fjs);}}(document,"script","twitter-wjs");')
    
  ),
  useShinyjs(),
  uiOutput("app"),
  # Application title
  headerPanel(
    list(tags$head(tags$style("body {background-color: white; }")),
         "FDRCLIM", HTML('<img src="picture2.png", height="100px",  
                         style="float:left"/>','<p style="color:grey"> FDR control of ExG associations </p>' ))
         ),
  theme = shinytheme("journal") , 
  jqui_draggabled( sidebarPanel(
    selectInput('file', 'Choose ExG association', setNames(files, files)),
    tags$hr(),
    checkboxInput('header', 'Header', TRUE),
    wellPanel(a(h4('Please cite us:'),  href = "https://www.nature.com/articles/s41559-018-0754-5", h6('Ferrero-Serrano, Á & Assmann SM. Phenotypic and genome-wide association with the local environment of Arabidopsis. Nature Ecology & Evolution. doi: 10.1038/s41559-018-0754-5 (2019)' ))),
    
    wellPanel(
      p( strong( HTML("&pi;<sub>0</sub>"), "estimate inputs")),
      selectInput("pi0method", p("Choose a", HTML("&pi;<sub>0</sub>"), "method:"), 
                  choices = c("smoother", "bootstrap")),
      sliderInput(inputId = "lambda", label = p(HTML("&lambda;"),"range"),
                  min = 0, max = 1, value = c(0, 0.95), step = 0.01),
      
      numericInput("step", p(HTML("&lambda;"),"step size:"), 0.05),
      numericInput("sdf", "smooth df:", 3.0),
      checkboxInput(inputId = "pi0log", label = p(HTML("&pi;<sub>0</sub>"), "smoother log"),     value = FALSE)
    ),
    wellPanel(
      p(strong("Local FDR inputs")),
      selectInput("transf", "Choose a transformation method:", 
                  choices = c("probit", "logit")),
      checkboxInput(inputId = "trunc", label = "truncate local FDR values",     value = TRUE),
      checkboxInput(inputId = "mono", label = "monotone",     value = TRUE),
      numericInput("adj", "adjust:", 1.5),
      numericInput("eps", "threshold:", 10^-8)
    ),
    wellPanel(
      p(strong("Output")),
      sliderInput("fdr", 
                  "FDR level:",
                  step = 0.01,
                  value = 0.05,
                  min = 0, 
                  max = 1),
      checkboxInput(inputId = "pfdr", label = "pfdr",     value = FALSE)
    ), wellPanel(a("Tweets by @ClimTools", class="twitter-timeline"
                   , href = "https://twitter.com/ClimTools"), style = "overflow-y:scroll; max-height: 1000px"
    ),h6('Contact us: clim.tools.lab@gmail.com'))
    
  ),
  mainPanel(  
    ###add code to get rid of error messages on the app.   
    tags$style(type="text/css",
               ".shiny-output-error { visibility: hidden; }",
               ".shiny-output-error:before { visibility: hidden; }"
    ),
    tabsetPanel(id="tabSelected",
                tabPanel("About", h4("Using the App"), uiOutput("about"), h4("References"), uiOutput("ref")),
              # tabPanel("Figures", h4("Plot"), plotOutput("qvaluePlot"), h4("Histogram"), plotOutput("qvalueHist"),   h4("Summary"),  verbatimTextOutput("summary") ),
              tabPanel("Figures", uiOutput("subTabs")),
              tabPanel("Help", uiOutput("help")))
    
  )
))

