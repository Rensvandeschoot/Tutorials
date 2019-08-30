# --------------------------------------------------------
# FBI - First Bayesian Inference
# Lion Behrens, Sonja D. Winter and Rens van de Schoot
# February 2018
# User Interface
# --------------------------------------------------------

ui <- fluidPage(# Layout
                theme="simplex.min.css",
                tags$style(type="text/css", "label {font-size: 12px;}", ".recalculating {opacity: 1.0;}"),
                tags$hr(style="border-color: blue;"),
                
                # Application title and links
                tags$h2("FBI: First Bayesian Inference ", img(src='utrecht.png', align = "right", height=112, width=405)),
                p("Version 2.0, created by", tags$a(href="https://lion-be.github.io/", "Lion Behrens,"), tags$a(href="https://thequantitativepsyche.wordpress.com/", "Sonja D. Winter"), "and", 
                  tags$a(href="https://www.rensvandeschoot.com/", "Rens van de Schoot")), 
                actionButton("disclaimer", label = "Show Disclaimer"),
                br(),  
                br(),      
                p("This Shiny-app was designed to aid in teaching the basics of Bayesian estimation.
                  The focus of the analysis presented here is on accurately estimating the mean of IQ 
                  using simulated data. This implies that priors and data should be generated within the theoretical boundaries 
                  of an imaginary IQ test with a minimum and maximum possible scores of 40-180. 
                  Specifying priors and/or generating data outside these limits might cause the app to return 
                  with unwanted solutions. For more details see..."),
                p("Van de Schoot, R., Kaplan, D., Denissen, J., Asendorpf, J. B., Neyer, F. J., & Aken, M. A. (2014).", tags$a(href="https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4158865/", "A gentle introduction to Bayesian analysis: applications to developmental research. "),
                  "Child development, 85(3), 842-860."),
                tags$hr(style="border-color: blue;"),
                
fluidRow(
    column(4,tags$h3("1. Choose a prior distribution"),
           p("Choose the parameters of your prior distribution. Hit the button below to create your prior."),
           wellPanel(
      
           radioButtons(inputId = "prior", label = "Prior Distributions",
                        choices = list("Uniform" = "runif",
                                       "Truncated Normal" = "trnorm")),
          conditionalPanel(
             condition = "input.prior == 'runif'",
             numericInput("min", label = "Minimum", value = 40),
             numericInput("max", label = "Maximum", value = 180)
           ),
           conditionalPanel(
             condition = "input.prior == 'trnorm'",
             numericInput("meant", label = "Prior Mean", value = 90),
             numericInput("vart", label = "Prior Variance", value = 10),
             numericInput("lbound", label = "Lower bound", value = 40),
             numericInput("ubound", label = "Higher bound", value = 180)
           ),  
           
           actionButton("construct_prior", label = "Construct Prior")
           
    )),
  
    
    column(4, tags$h3("2. Construct your data and likelihood"),
            p("You can simulate data from a truncated normal distribution with 40 and 180 as boundary values. From this data, a 
              likelihood function will be constructed."),  
            
            wellPanel(
          
              strong("Parameters of your simulated data"),
              
              br(),
              br(),
              
              numericInput("meant2", label = "Data Mean", value = 100),
              numericInput("vart2", label = "Data Standard Deviation", value = 15),
              numericInput("n2", label = "Sample Size", value = 22),
              
              br(),
              
              strong("This will lead to the following parameters of the likelihood function"), 
              br(),
              
              p(textOutput("likeli_mean")),
              p(textOutput("likeli_var")),
              
              br(),
              
              actionButton("generate", label = "Construct Dataset and Likelihood")
            
    )),
    
    column(4, tags$h3("3. Find your posterior"),
           
           p("Hit the button to run the model to find the
             posterior mean of based on your uploaded data and chosen
             prior distribution."),
           wellPanel(
             actionButton("run", label = "Construct Posterior (default)"),
             br(),
             br(),
             actionButton("runsigmaunknown", label = "Run with sigma unknown"),
             br(),
             br(),
           p("If you change your data or prior, and you
             want to see its effect, just rerun the model by clicking the
             button again.")
             )
    )),


  fluidRow(
    column(12, 
           h2("Plot"),
           br(),
           plotOutput("hist")
  )),


  fluidRow(
    column(12,
           h2("Summary"),
           br(),
           tableOutput("tbl"))
  ))