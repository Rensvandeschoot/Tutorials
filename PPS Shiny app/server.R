# last edited 07-02-2019 by Laurent Smeets


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



server <- function(input, output, session) {
  uu_color <- " #ffcd00"
  
  observeEvent(input$disclaimer, {
    
    
    # Define Pop-Up with Terms & Conditions
    showModal(modalDialog(
      title = "Disclaimer",
      
      "This project is funded by the Netherlands organization for scientific research (NWO); 
      grant number VIDI-452-14-006. Purpose of the service 'utrecht-university.shinyapps.io' 
      is to provide a digital place for trying out, evaluating and/or comparing methods developed
      by researchers of Utrecht University for the scientific community worldwide. Filing the app 
      and its contents for citing and referencing purposes is not permitted. The web application is 
      provided 'as is' and 'as available' and is without any warranty. Your use of this web application
      is solely at your own risk. By using this app you agree to be bound by the above terms."))
  })
  
  observeEvent(input$answer1, {
    showModal(modalDialog(
      title = "Answer",
      withMathJax("$$Delay_i =  \\beta_{intercept}\ + \\beta_{age} * Age_i + \\beta_{age^2} *  Age^2_i + e_i$$ ")))
    #withMathJax(HTML("Delay =  \\(\\beta_{intercept}\\) + \\(\\beta_{age}\\)* Age_i + \\(\\beta_{age^2}\\)* \\Age^2_i\\ + e_i"))))
  })
  
  
  observeEvent(input$answer2, {
    showModal(modalDialog(
      title = "Answer",
      p("This effect would look like a negative parabola (n-shaped)."),
      tags$img(src="plot.png", align = "left",width=350)))
  })
  
  
  observeEvent(input$answer3, {
    showModal(modalDialog(
      title = "Answer",
      
      "You can see this in the plot below. Note that the color of the variance of
      the linear effect is coral and that of the quadratic effect is orange.
      Let's focus on the widening of the variance of the quadratic effect. When you slightly increase
      the standard deviation of the quadratic effect (please note that the scales of variance
      sliders are different), it leads to a large widening of the quadratic effect ribbon over time. Any difference from the mean of
      the quadratic effect is multiplied by age squared, so for example, for a 50-year-old, it is multiplied by 2500."))
  })
  
  
  
  output$distPlot_1 <- renderPlot({
    P1<-data.frame() %>%
      ggplot()        +
      geom_point()    +
      xlim(0, 120)    +
      ylim(-250, 1000)+
      labs(xlab  = "Age (in years)", 
           ylab  = "Delay (in months)",
           title = "Parameter Space")+
      annotate(geom  = "rect", 
               xmin  = input$range1[1], 
               xmax  = input$range1[2],
               ymin  = input$range2[1], 
               ymax  = input$range2[2], 
               alpha = .1,
               col   = substr(uu_color,2, 8))+
      theme_light()
    
    P2<-data.frame() %>%
      ggplot()+
      geom_point()+xlim(0, 120)+ylim(-250, 1000)+
      labs(xlab= "Age (in years)", 
           ylab="Delay (in months)",
           title= "Plausible Parameter Space")+
      annotate(geom= "rect", 
               xmin  = input$range1[1], 
               xmax  = input$range1[2], 
               ymin  = input$range2[1], 
               ymax  = input$range2[2], 
               alpha = .1, 
               col   = substr(uu_color,2, 8))+
      coord_cartesian(xlim = c(input$range1[1], input$range1[2]),
                      ylim = c(input$range2[1], input$range2[2]))+
      theme_light()
    
    grid.arrange(P1, P2, 
                 left   ="Delay (in months)", 
                 bottom = "Age (in years)")
    
    
    
  })
  
  
  output$distPlot_2 <- renderPlot({
    # based on the the input of the user we calculate the regression coefficients
    age <- 0:120
    delay<-input$p1*age + input$p2*(age^2)+input$p3
    delay_intercept <- input$p3
    delay_linear    <- input$p1*age + input$p3
    delay_quadratic <- input$p1*age + input$p2*(age^2) + input$p3
    
    data=data.frame(age, delay, delay_intercept, delay_linear, delay_quadratic)
    
    # this is the code to make the box
    x1<-input$range1[1]
    x2<-input$range1[2]
    y1<-input$range2[1]
    y2<-input$range2[2]
    
    
    colourintercept  <- "blue"
    colourlinear     <- "coral2"
    colourquadratic  <- "orange"
    
    if(input$check_box_1==TRUE){
      
      P<-ggplot(data   = data, aes(x = age, y = delay))+
        geom_line(data = filter(data, age>x1 & age<x2 & delay_intercept>y1 & delay_intercept<y2), aes(x = age, y = delay_intercept),colour = colourintercept, size = 1.3)+
        geom_line(data = filter(data, age>x1 & age<x2 & delay_linear>y1 & delay_linear<y2),       aes(x = age, y = delay_linear),   colour = colourlinear,    size = 1.3)+
        geom_line(data = filter(data, age>x1 & age<x2 & delay_quadratic>y1 & delay_quadratic<y2), aes(x = age, y = delay_quadratic),colour = colourquadratic, size = 1.3)+
        geom_line(aes(x = age, y = delay_intercept), colour = colourintercept, size = 1.3, linetype = "dotted")+
        geom_line(aes(x = age, y = delay_linear),    colour = colourlinear,    size = 1.3, linetype = "dotted")+
        geom_line(aes(x = age, y = delay_quadratic), colour = colourquadratic, size = 1.3, linetype = "dotted")+
        coord_cartesian(xlim = c(0,120), ylim = c(-200, 1000))+
        labs(title = "Parameter Space", 
                 y = "Delay (in months)",
                 x = "Age (in years)")+
        annotate(geom  = "rect",
                 xmin  = input$range1[1], 
                 xmax  = input$range1[2], 
                 ymin  = input$range2[1], 
                 ymax  = input$range2[2], 
                 alpha = .1,
                 col   = substr(uu_color,2, 8))+
        theme_light()
      
      P_legend <- ggplot(data = filter(gather(data, key = "Parameter", value = "value", - age), Parameter %in% c("delay_intercept","delay_linear", "delay_quadratic" )))+
                  geom_line(aes(x = age, y = value, col = Parameter))+
                  scale_colour_manual(values = c(colourintercept, colourlinear, colourquadratic),
                            labels = c("intercept", "intercept + linear effect", "intercept + linear effect + quadratic effect "))+
        theme(legend.key.width = unit(3,"cm"))
      legend <- cowplot::get_legend(P_legend)
      
      lay <- rbind(c(1,1,1,1),
                   c(1,1,1,1),
                   c(1,1,1,1),
                   c(2,2,2,2))
      
      grid.arrange(P, ggdraw(legend), layout_matrix = lay)
    }
    
    else{
      P <- ggplot(data = data,aes(x = age, y = delay))+
        geom_line(aes(x = age, y = delay_intercept), colour = colourintercept, size = 1.3)+
        geom_line(aes(x = age, y = delay_linear),    colour = colourlinear,    size = 1.3)+
        geom_line(aes(x = age, y = delay_quadratic), colour = colourquadratic, size = 1.3)+
        scale_x_continuous(name = "Age (in years)")+
        coord_cartesian(xlim = c(input$range1[1], input$range1[2]), 
                        ylim = c(input$range2[1], input$range2[2]))+
        labs(title = "Plausible Values", 
                 y = "Delay (in months)", 
                 x = "Age (in years)")+
        annotate(geom  = "rect", 
                 xmin  = input$range1[1],
                 xmax  = input$range1[2], 
                 ymin  = input$range2[1], 
                 ymax  = input$range2[2], 
                 alpha = .1, 
                 col   = substr(uu_color,2, 8))+
        theme_light()
      
      P_legend<-ggplot(data = filter(gather(data, key = "Parameter", value = "value", - age), Parameter %in% c("delay_intercept","delay_linear", "delay_quadratic" )))+
        geom_line(aes(x = age, y = value, col = Parameter))+
        scale_colour_manual(values = c(colourintercept, colourlinear, colourquadratic),
                            labels = c("intercept", "intercept + linear effect", "intercept + linear effect + quadratic effect "))+
        theme(legend.key.width = unit(3,"cm"))
      legend <- cowplot::get_legend(P_legend)
      
      lay <- rbind(c(1,1,1,1),
                   c(1,1,1,1),
                   c(1,1,1,1),
                   c(2,2,2,2))
      
      grid.arrange(P, ggdraw(legend), layout_matrix = lay)
      
      
    }
    
  })
  
  
  
  output$distPlot_3 <- renderPlot({
    # based on the the input of the user we calculate the regression coefficients
    age   <- 0:120
    delay <- input$p1*age + input$p2*(age^2)+input$p3
    delay_intercept <- input$p3
    delay_linear    <- input$p1*age + input$p3
    delay_quadratic <- input$p1*age + input$p2*(age^2)+input$p3
    
    
    if(input$p9=="66.7%"){
      ribonrange <- .6827
    }
    if(input$p9=="95%"){
      ribonrange <- .9545
      
    }
    if(input$p9== "99.7%"){
      ribonrange <- .9973
    }
    
    
    variance.intercept<-input$p8
    variance.age<-input$p6
    variance.age2<-input$p7
    
    #delay_low <- qnorm((1-ribonrange),input$p3, sd=sqrt(variance.intercept))+(qnorm(1-ribonrange,input$p1, sd=sqrt(variance.age))*age)+(qnorm(1-ribonrange,input$p2, sd=sqrt(variance.age2))*(age^2))
    delay_low <- qnorm((1-ribonrange),input$p3, sd=variance.intercept)+(qnorm(1-ribonrange,input$p1, sd=variance.age)*age)+(qnorm(1-ribonrange,input$p2, sd=variance.age2)*(age^2))
    
    #delay_high<- qnorm(ribonrange,input$p3, sd=sqrt(variance.intercept))+(qnorm(ribonrange,input$p1, sd=sqrt(variance.age))*age)+(qnorm(ribonrange,input$p2, sd=sqrt(variance.age2))*(age^2))
    delay_high<- qnorm(ribonrange,input$p3, sd=variance.intercept)+(qnorm(ribonrange,input$p1, sd=variance.age)*age)+(qnorm(ribonrange,input$p2, sd=variance.age2)*(age^2))
    
    delay_low_intercept <- qnorm((1-ribonrange),input$p3, sd=variance.intercept)
    #delay_low_intercept <- qnorm((1-ribonrange),input$p3, sd=sqrt(variance.intercept))
    
    delay_high_intercept <- qnorm(ribonrange,input$p3, sd=variance.intercept)
    #delay_high_intercept <- qnorm(ribonrange,input$p3, sd=sqrt(variance.intercept))
    
    delay_low_linear <- input$p3+(qnorm(1-ribonrange,input$p1, sd=variance.age)*age)
    #delay_low_linear <- input$p3+(qnorm(1-ribonrange,input$p1, sd=sqrt(variance.age))*age)
    
    #delay_high__linear <-input$p3+(qnorm(ribonrange,input$p1, sd=sqrt(variance.age))*age)
    delay_high__linear <-input$p3+(qnorm(ribonrange,input$p1, sd=variance.age)*age)
    
    delay_low_quadratic <- input$p3+input$p1*age+(qnorm(1-ribonrange,input$p2, sd=variance.age2)*(age^2))
    #delay_low_quadratic <- input$p3+input$p1*age+(qnorm(1-ribonrange,input$p2, sd=sqrt(variance.age2))*(age^2))
    
    delay_high_quadratic <- input$p3+input$p1*age+(qnorm(ribonrange,input$p2, sd=variance.age2)*(age^2))
    #delay_high_quadratic <- input$p3+input$p1*age+(qnorm(ribonrange,input$p2, sd=sqrt(variance.age2))*(age^2))
    
    data=data.frame(age, delay, delay_low, delay_high, delay_low_intercept, delay_high_intercept, delay_intercept, delay_linear, delay_low_linear, delay_high__linear, delay_quadratic, delay_low_quadratic, delay_high_quadratic)
    
    
    
    # this is the code to make the box
    x1 <- input$range1[1]
    x2 <- input$range1[2]
    y1 <- input$range2[1]
    y2 <- input$range2[2]
  
    
    colourintercept  <- "blue"
    colourlinear     <- "coral2"
    colourquadratic  <- "orange"
    
    if(input$check_box_2==FALSE){
      if(input$check_box_3==TRUE){
        
        P<-ggplot(data   = data, aes(x = age, y = delay))+
          geom_line(data = filter(data, age>x1 & age<x2 & delay_intercept>y1 &delay_intercept<y2), aes(x=age, y=delay_intercept),colour=colourintercept, size=1.3)+
          geom_line(data = filter(data, age>x1 & age<x2 & delay_linear>y1 &delay_linear<y2), aes(x=age, y=delay_linear),colour=colourlinear, size=1.3)+
          geom_line(data = filter(data, age>x1 & age<x2 & delay_quadratic>y1 &delay_quadratic<y2), aes(x=age, y=delay_quadratic),colour=colourquadratic, size=1.3)+
          geom_line(  aes(x    = age, y = delay_intercept), colour = colourintercept, size=1.3,   linetype= "dotted")+
          geom_ribbon(aes(ymin = delay_low_intercept, ymax = delay_high_intercept),   fill = colourintercept, alpha=0.3)+
          geom_line(  aes(x    = age, y=delay_linear), colour = colourlinear,         size = 1.3, linetype= "dotted")+
          geom_ribbon(aes(ymin = delay_low_linear, ymax=delay_high__linear),          fill = colourlinear, alpha=0.3)+
          geom_line(  aes(x    = age, y=delay_quadratic),colour=colourquadratic,      size = 1.3, linetype= "dotted")+
          geom_ribbon(aes(ymin = delay_low_quadratic, ymax=delay_high_quadratic),     fill = colourquadratic, alpha=0.3)+
          coord_cartesian(xlim=c(0,120), ylim=c(-200, 1000))+
          scale_x_continuous(name = "Age (in years)")+
          scale_y_continuous(name = "Delay (in months)")+
          labs(title= "Parameter Space")+
          annotate(geom  = "rect", 
                   xmin  = input$range1[1], 
                   xmax  = input$range1[2],
                   ymin  = input$range2[1],
                   ymax  = input$range2[2], 
                   alpha = .1,
                   col   = substr(uu_color,2, 8))+
          theme_light()
        
        P_legend<-ggplot(data = filter(gather(data, key = "Parameter", value= "value", - age), Parameter %in% c("delay_intercept","delay_linear", "delay_quadratic" )))+
          geom_line(aes(x = age, y = value, col = Parameter))+
          scale_colour_manual(values = c(colourintercept, colourlinear, colourquadratic),
                              labels = c("intercept", "intercept + linear effect", "intercept + linear effect + quadratic effect "))+
          theme(legend.key.width = unit(3,"cm"))
        
        legend <- cowplot::get_legend(P_legend)
        
        lay <- rbind(c(1,1,1,1),
                     c(1,1,1,1),
                     c(1,1,1,1),
                     c(2,2,2,2))
        
        grid.arrange(P, ggdraw(legend), layout_matrix = lay)
        
      }else{
        P <- ggplot(data      = data,aes(x = age, y = delay))+
          geom_line(aes(x     = age, y=delay_intercept),colour=colourintercept, size = 1.3)+
          geom_ribbon(aes(ymin= delay_low_intercept, ymax = delay_high_intercept), fill = colourintercept, alpha = 0.3)+
          geom_line(aes(x = age, y = delay_linear),colour = colourlinear, size=1.3)+
          geom_ribbon(aes(ymin=delay_low_linear, ymax     = delay_high__linear), fill = colourlinear, alpha = 0.3)+
          geom_line(aes(x=age, y=delay_quadratic),colour  = colourquadratic, size = 1.3)+
          geom_ribbon(aes(ymin=delay_low_quadratic, ymax  = delay_high_quadratic), fill = colourquadratic, alpha = 0.3)+
          scale_y_continuous(name = "Delay (in months)")+
          scale_x_continuous(name = "Age (in years)")+
          coord_cartesian(xlim = c(input$range1[1], input$range1[2]), 
                          ylim = c(input$range2[1], input$range2[2]))+
          labs(title = "Plausible Values")+
          annotate(geom  = "rect", 
                   xmin  = input$range1[1],
                   xmax  = input$range1[2],
                   ymin  = input$range2[1],
                   ymax  = input$range2[2],
                   alpha = .1,
                   col   = substr(uu_color,2, 8))+
          theme_light()
        
        P_legend<-ggplot(data = filter(gather(data, key="Parameter", value= "value", - age), Parameter %in% c("delay_intercept","delay_linear", "delay_quadratic" )))+
          geom_line(aes(x = age, y = value, col = Parameter))+
          scale_colour_manual(values = c(colourintercept, colourlinear, colourquadratic),
                              labels = c("intercept", "intercept + linear effect", "intercept + linear effect + quadratic effect "))+
          theme(legend.key.width = unit(3,"cm"))
        
        legend <- cowplot::get_legend(P_legend)
        
        lay <- rbind(c(1,1,1,1),
                     c(1,1,1,1),
                     c(1,1,1,1),
                     c(2,2,2,2))
        
        grid.arrange(P, ggdraw(legend), layout_matrix = lay)
        
      }}
    else{
      if(input$check_box_3 == TRUE){
        P <- ggplot(data = data, aes(x = age, y = delay))+
          geom_line(data =filter(data, age>x1 & age<x2 & delay>y1 &delay<y2), aes(x = age, y = delay),colour=colourquadratic, size=1.3)+
          geom_line(aes(x = age, y = delay), colour = colourquadratic, size=1.3, linetype = "dotted")+
          geom_ribbon(aes(ymin = delay_low, ymax = delay_high), fill = colourquadratic, alpha = 0.3)+
          coord_cartesian(xlim = c(0,120),  ylim = c(-200, 1000))+
          scale_x_continuous(name = "Age (in years)")+
          scale_y_continuous(name = "Delay (in months)")+
          labs(title = "Parameter Space")+
          annotate(geom  = "rect",
                   xmin  = input$range1[1],
                   xmax  = input$range1[2],
                   ymin  = input$range2[1], 
                   ymax  = input$range2[2], 
                   alpha = .1, 
                   col   = substr(uu_color,2, 8))+
          theme_light()
        
        P_legend<-ggplot(data = data)+
          geom_line(aes(x =age, y = delay, color = "Quadratic effect with combined variances"))+
          scale_color_manual(name = "Parameter", values = c("Quadratic effect with combined variances" = colourquadratic))+
          theme(legend.key.width = unit(3,"cm"))
        
        
        legend <- cowplot::get_legend(P_legend)
        
        lay <- rbind(c(1,1,1,1),
                     c(1,1,1,1),
                     c(1,1,1,1),
                     c(2,2,2,2))
        
        grid.arrange(P, ggdraw(legend), layout_matrix = lay)
        
      }else{
        P <- ggplot(data   = data, aes(x = age, y = delay))+
          geom_line(colour = colourquadratic, size = 1.3)+
          geom_ribbon(aes(ymin = delay_low, ymax = delay_high), fill = colourquadratic, alpha = 0.3)+
          scale_y_continuous(name = "Delay (in months)")+
          scale_x_continuous(name = "Age (in years)")+
          coord_cartesian(xlim = c(input$range1[1], input$range1[2]), 
                          ylim = c(input$range2[1], input$range2[2]))+
          labs(title = "Plausible Values")+
          annotate(geom  = "rect", 
                   xmin  = input$range1[1],
                   xmax  = input$range1[2],
                   ymin  = input$range2[1], 
                   ymax  = input$range2[2], 
                   alpha = .1, 
                   col   = substr(uu_color,2, 8))+
          theme_light()
        
        
        P_legend<-ggplot(data = data)+
          geom_line(aes(x = age, y = delay, color = "Quadratic effect with combined variances"))+
          scale_color_manual(name = "Parameter", values = c("Quadratic effect with combined variances" = colourquadratic))+
          theme(legend.key.width = unit(3,"cm"))
        
        
        legend <- cowplot::get_legend(P_legend)
        
        lay <- rbind(c(1,1,1,1),
                     c(1,1,1,1),
                     c(1,1,1,1),
                     c(2,2,2,2))
        
        grid.arrange(P, ggdraw(legend), layout_matrix = lay)
      }}
    
    
    
    
    
  })
  
  
  
  output$Priors <- renderUI(
    withMathJax(
      HTML(paste0("Different software requires different specification of the hyperparameters. Look at the specification that is relevant for you.  <br><br>",
                  "<b>Parametrized as N(mean, variance)</b><br>",
                  "The hyperparameters of the priors you have selected correspond to:",
                  "<ul><li>Intercept  (\\(\\beta_{intercept}\\))   ~ N(", input$p3,", ", input$p8, ")",
                  "</li><li> regression coefficient age  (\\(\\beta_{age}\\))  ~ N(", input$p1,", ", input$p6,")",
                  "</li><li> regression coefficient squared (\\(\\beta_{age^2}\\))  ~ N(", input$p2,", ", input$p7, ")","</li></ul>",
                  "<b>Parametrized as N(mean, sd) (ex. Stan)</b><br>",
                  "The hyperparameters of the priors you have selected correspond to:",
                  "<ul><li>Intercept  (\\(\\beta_{intercept}\\))   ~ N(", input$p3,", ", signif(sqrt(input$p8),2), ")",
                  "</li><li> regression coefficient age  (\\(\\beta_{age}\\))  ~ N(", input$p1,", ", signif(sqrt(input$p6),2),")",
                  "</li><li> regression coefficient squared (\\(\\beta_{age^2}\\))  ~ N(", input$p2,", ", signif(sqrt(input$p7),2), ")","</li></ul>",
                  "<b>Parametrized as N(mean, precision), precision is 1/variance (ex. JAGS)</b><br>",
                  "The hyperparameters of the priors you have selected correspond to:",
                  "<ul><li>Intercept  (\\(\\beta_{intercept}\\))   ~ N(", input$p3,", ", signif(1/input$p8,2), ")",
                  "</li><li> regression coefficient age  (\\(\\beta_{age}\\))  ~ N(", input$p1,", ", signif(1/(input$p6),2),")",
                  "</li><li> regression coefficient age squared(\\(\\beta_{age^2}\\))  ~ N(", input$p2,", ", signif(1/(input$p7),2), ")","</li></ul>")
      )))
  
  
}
