# last edited 18-01-2019 by Laurent Smeets
# last edited 28-09-2020 by Ihnwhi Heo

library("shinydashboard")
library("shiny") 
library("gridExtra") 
library("shinyBS")
library("shinyWidgets") 
library("cowplot") 
library("shinyjs") 
library("grid")
library("reshape") 
library("rmarkdown") 
library("knitr")
library("tidyverse")


ui <- dashboardPage(

  skin = "black",

  dashboardHeader(title = "Plausible Parameter Space!", titleWidth = 350), 
  dashboardSidebar(width = 350,
                   sidebarMenu(
                     menuItem("Introduction",                              tabName = "tab1"),
                     menuItem("Step 1. Set up Parameter Space",            tabName = "tab2"),
                     menuItem("Step 2: Set prior regression coefficients", tabName = "tab3"),
                     menuItem("Step 3: Quantify uncertainty",              tabName = "tab4"),
                     menuItem("Step 4: Your Priors",                       tabName = "tab5"),
                     HTML("<br>"), 
                     img(src="UU_logo_EN_CMYK.png", align = "right",  width=330)
                   )), 
  dashboardBody(
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "UU_theme_Laurent.css")
    ),
    

    tabItems(
      
      tabItems(
      
      tabItem(tabName = "tab1",   # Application title and links
              tags$h2("Influence of Priors "),
              p("Version 0.3.2, created by", tags$a(href="https://www.rensvandeschoot.com/colleagues/laurent-smeets/", "Laurent Smeets"), "and", 
                tags$a(href="https://www.rensvandeschoot.com/", "Rens van de Schoot")),
              withMathJax(p("How to cite this Shiny App in APA style",
                            br(),
                            "Smeets, L., & Van de Schoot, R. (2020, September 15). Code for the ShinyApp to Determine the Plausible Parameter Space for the PhD-delay Data (Version v1.0). Zenodo.", tags$a(href="https://doi.org/10.5281/zenodo.4030288", "https://doi.org/10.5281/zenodo.4030288"))),
              actionButton("disclaimer", label = "Show Disclaimer"),
              br(),  
              br(),      
              p("This Shiny App is designed to help users define their priors in a linear regression
                with two regression coefficients. Using the same example as in the software tutorials 
                on this website, users are asked to specify their plausible parameter space and their 
                expected prior means and uncertainty around these means. The Ph.D. delay example has been used an
                easy-to-go introduction to Bayesian inference. In this example the linear and quadratic effect of 
                age on Ph.D. delay are estimated. Users learn about specifying a linear and a quadratic effect in the same model with the interactive visual plots, about how to think about plausible parameter spaces, and about 
                the specification of normally distributed priors for regression coefficients."),
              withMathJax(p("The data is based on data described in Van de Schoot, R., Yerkes, M.A., Mouw, J.M. & Sonneveld, H. (2013).", tags$a(href="https://www.rensvandeschoot.com/what-took-them-so-long-explaining-phd-delays-among-doctoral-candidates/", "What Took Them So Long? Explaining PhD Delays among Doctoral Candidates."), "PLoS One, 8(7): e68839.")),
              withMathJax(p("You can cite the Ph.D. delay dataset in APA style as follows:", "Van de Schoot, R. (2020). PhD-delay Dataset for Online Stats Training [Data set]. Zenodo.", tags$a(href="https://doi.org/10.5281/zenodo.3999424", "https://doi.org/10.5281/zenodo.3999424")))),
      
      
      
      tabItem(tabName = "tab2",   # Application title and links
              fluidRow(box(width=12, title = "Step 1. Set up Parameter Space", status = "primary", solidHeader = TRUE,
                           p("Think of what you believe to be a plausible parameter space (just a fancy term for reasonable values of your variable). 
                             In this example, you are interested in the (non-linear) relationship between age and delay in PhD completion. 
                             Start with defining what you believe to be a reasonable range for age. 
                             Think about what you believe to be the youngest age someone can acquire a PhD (delay included) and what the oldest age might
                             be. Then, define the delay (in months) you believe to be reasonable. A negative delay is possible 
                             (someone finishes a PhD ahead of schedule). Think about how many months someone can finish ahead of 
                             schedule and what you believe to be the maximum time that someone can be delayed. Adjust the sliders, 
                             Range Age and Range Delay, in the left column to set your plausible parameter space. You can see that 
                             in the two plots in the right-hand column the parameter space is adjusted when you move the sliders."))),
              fluidRow(box(width=7,  title = "Set up Parameter Space", status = "primary", solidHeader = TRUE,
                           p("Use the sliders to set up min and max of both age (in years) and delay (in months). Think about what you believe to be plausible values."),
                           sliderInput(inputId="range1", label= "Range Age", min=0, max=120, value=c(1,119)),
                           sliderInput(inputId="range2", label= "Range Delay",min=-200, max=1000, value=c(-180, 900))),
                       
                       box(width=5, title = "Plots", status = "primary", solidHeader = TRUE,
                           tags$h3("Plots"), 
                           plotOutput("distPlot_1"),
                           br(), 
                           tags$h4("If you are satisfied with your parameter space continue to step 2."))) 
                           ),
      
      
      tabItem(tabName = "tab3",   # Application title and links
              fluidRow(box(width=12, title = "Step 2: Set prior regression coefficients", status = "primary", solidHeader = TRUE,  
                                      p("The next step is to think about what you believe to be the intercept, 
                                        the linear effect and the quadratic effect. The data is not centred,
                                        which means that the intercept represents the PhD delay of a 0-year-old.
                                        The linear effect is the expected increase in delay over time by any number 
                                        of months. For example, a linear effect of 3 means that you expect that with
                                        an increase in age of 1 year, the expected delay is 3 more months. 
                                        The quadratic effect is the non-linear effect over time. Such a quadratic
                                        effect is used in models with a non-linear relationship. For example, one can see that:"),
                           tags$ul(
                             tags$li("If you specify both a positive linear effect and a positive quadratic effect,
                                     you can expect an increase for delay with age, accelerating with growing age."), 
                             tags$li("If you specify both a negative linear effect and a negative quadratic effect, 
                                     you can expect a decrease for delay with age, accelerating with growing age."), 
                             tags$li("If you specify a positive linear and a smaller negative quadratic effect, you can expect an 
                                     initial increase of delay with age, until a certain age when delay starts to become smaller again."),
                             tags$li("If you specify a negative linear and a smaller positive quadratic effect, you can expect an initial 
                                     decrease of delay with age, until a certain age when delay starts to become larger again.")),
                           tags$h3("Question:"), 
                           tags$em("What is the complete regression formula?"), 
                           p(), 
                           actionButton("answer1", label = "Show Answer"),
                           p(), 
                           tags$h3("Question:"), 
                           tags$em("Suppose your prior belief/expectation is that there will be a positive linear effect and a negative quadratic effect of Age on Delay. 
                                   How would that expectation translate into a plot visualizing the effect of Age (x-axis) on Delay (y-axis)?"),
                           p(), 
                           actionButton("answer2", label = "Show Answer"),
                           p(), 
                           p("You can 'play' around with the sliders until you have found your optimal expected 
                             combination between the linear and quadratic effect. Please note that:"),
                           tags$ol(
                             tags$li("You should never use a quadratic effect in your regression model 
                                     without also using the linear effect."), 
                             tags$li("You preferably would base your priors on earlier findings, expert knowledge, etc.."), 
                             tags$li("You should always specify your priors before looking at your data."),
                             tags$li("In this example, we only specify a prior for the three regression coefficients 
                                     (Intercept + linear effect + quadratic effect) and not for the error terms."))
                             )),
              
              fluidRow(box(width=7,  title = "Prior Regression Coefficients", status = "primary", solidHeader = TRUE,
                           withMathJax(p("Use the sliders to set the values for the regression coefficients."),
                           sliderInput(inputId="p3",  min=-250, max=250, step=.5,
                                       label="\\(\\beta_{intercept}\\)", value=0),
                           sliderInput(inputId="p1", min=-5, max=5, step=.1,
                                       label="\\(\\beta_{age}\\)", value=0),
                           sliderInput(inputId="p2",  min=-.1, max=.1, step=.005,
                                       label="\\(\\beta_{age^2}\\)", value=0),
                           checkboxInput("check_box_1", "Show total parameter space plot"))),
                       
                       box(width=5, title = "Plot", status = "primary", solidHeader = TRUE,
                           plotOutput("distPlot_2"),
                           br(), 
                           tags$h4("If you are satisfied with your prior means, please continue to step 3."))) 
                           ),
      
      
      
      tabItem(tabName = "tab4",   # Application title and links
              fluidRow(box(width=12, title = "Step 3: Quantify uncertainty", status = "primary", solidHeader = TRUE, 
                           p("Priors for the regression coefficients (or any prior for that matter) are never just a point estimate, 
                             but always a distribution. In this example, we only work with normal distributions, but most Bayesian
                             software will allow you to pick many different types of distributions. The regression coefficients you
                             specified are the means of these prior distributions. You will also have to set the standard deviations 
                             of the prior distributions. These variances (specified as standard deviations) are a measure of uncertainty 
                             of your regression coefficients. The smaller the variance, the surer you are about your regression coefficient.
                             Important: these variances are measured on the same scale as the regression coefficients. A variance that is
                             small for the intercept might be relatively large for the quadratic effect. This means you always have to be 
                             careful about the default prior of any Bayesian software package. You can adjust the standard deviations of the
                             priors by using the sliders."),
                           tags$h3("Question:"), 
                           tags$em("How can plots illustrate that a small change in the variance of the quadratic effect
                             has a large influence of the expected parameter space?"), 
                           p(),
                           actionButton("answer3", label = "Show Answer"),
                           p(), 
                           p("This app can be used to check whether the combination of priors you specified is reasonable. If you do not have any 
                             informative priors you want to use and are thus unsure about your prior beliefs, you might want to fill the whole 
                             plausible parameter space. However, it is important to understand that one has to quantify an uncertainty (variance) 
                             for all priors separately. This is the reason why, by default, the standard deviations are plotted separately. 
                             You can combine them by checking the Join Variances box. In the next tab you can find the priors as you have specified them."))),
              fluidRow(box(width=7,  title = "Standard Deviations Prior Regression Coefficients", status = "primary", solidHeader = TRUE,
                           p("Use the sliders to set the values for the prior variances (expressed in sd) of the regression coefficients."),
                           sliderInput(inputId="p8",  min=0, max=1000, step=1,
                                       label="Standard Deviation \\(\\beta_{intercept}\\)", value=0),
                           sliderInput(inputId="p6", min=0, max=100, step=1,
                                       label="Standard Deviation  \\(\\beta_{age}\\)", value=0),
                           sliderInput(inputId="p7",  min=0, max=1, step=.001,
                                       label="Standard Deviation  \\(\\beta_{age^2}\\)", value=0),
                           selectInput(inputId="p9", "Region:", 
                                       choices= c("66.7%", "95%", "99.7%"),
                                       label="Percentage of uncertainty sd ribbons represent"),
                           checkboxInput("check_box_2", "Join Variances"),
                           checkboxInput("check_box_3", "Show total parameter space plot")),
                       
                       box(width=5, title = "Plot", status = "primary", solidHeader = TRUE,
                           plotOutput("distPlot_3"),
                           br(), 
                           tags$h4("If you are satisfied with your priors, please have a look at them in the next tab.")))),
      
      
      
      tabItem(tabName = "tab5",   # Application title and links
              fluidRow(box(width=12, title = "Your priors", status = "primary", solidHeader = TRUE,
                           uiOutput("Priors"))
                       
                       
              )))))
