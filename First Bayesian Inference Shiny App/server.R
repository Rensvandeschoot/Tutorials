# --------------------------------------------------------
# FBI - First Bayesian Inference
# Lion Behrens, Sonja D. Winter and Rens van de Schoot
# February 2018
# Server Side
# --------------------------------------------------------

library(shiny)
library(shinyBS)
library(rjags)
library(coda)
library(msm) 
library(MASS)

server <- function(input, output) {
  
# ----------
# Pop-Up
# ----------  
  
  observeEvent(input$disclaimer, {
  
  
     # Define Pop-Up with Terms & Conditions
      showModal(modalDialog(
      title = "Disclaimer",
      
      "This project is funded by the  Netherlands organization for scientific research (NWO);
      grant number VIDI-452-14-006. Purpose of the service 'utrecht-university.shinyapps.io' is to provide a digital place 
      for trying out, evaluating and/or comparing methods developed by researchers of Utrecht 
      University for the scientific community worldwide. The app and its contents may not be 
      preserved in such a way that it can be cited or can be referenced to. The web application
      is provided 'as is' and 'as available' and is without any warranty. Your use of this web 
      application is solely at your own risk. By using this app you agree to be bound by the above terms."))
  })
  
# -----------------------
# Text in second column
# -----------------------
  
  output$likeli_mean <- renderText({ 
    c("Likelihood Mean = ", input$meant2)
  })
  
  output$likeli_var <- renderText({
    likeli_var <- (input$vart2/sqrt(input$n2))^2
    c("Likelihood Variance = ", round(likeli_var,digits=2))
  })
  
  output$text1 <- renderText({ paste("Parameters of your simulated data") })
  
  
 
  
# --------------------------------------------------
# Define Dataset used for Likelihood Construction
# --------------------------------------------------

  # Define dataset as input$file
  data <- reactive({ # This is done reactively once there is input$file
  inFile <- input$file
    
  # Prevent immediate error message if no datafile is uploadet yet
  if (is.null(inFile))
  return(NULL)
  unlist(read.csv(inFile$datapath, header=TRUE))})
  
  # Define alternative dataset as generated data
  gendata <- eventReactive(input$generate, { # Reactively based on "Generate" Button
    
  # Based on input paramters, construct random data from truncated normal distribution with exact mean and sd
  if (input$meant2 > 55 & input$meant2 < 165 & input$vart2 < 40){
  usedvar <- (input$vart2)^2
  data <- rtnorm(1, lower=((40 - input$meant2)/sqrt(usedvar)), upper=((180 - input$meant2)/sqrt(usedvar)))

  while (length(data) < input$n2) {
    sample <- rtnorm(1, lower=((40 - input$meant2)/sqrt(usedvar)), upper=((180 - input$meant2)/sqrt(usedvar)))
    data_copy = c(data, sample)
    data_copy_scaled = input$meant2 + sqrt(usedvar) * scale(data_copy)
  
  if (min(data_copy_scaled) >= 40 & max(data_copy_scaled) <= 180) {
      data = c(data, sample)}}
    
  scaled_data <- as.numeric(input$meant2 + sqrt(usedvar) * scale(data))
  scaled_data}
     
  else {
  
  usedvar <- (input$vart2)^2
  data <- rtnorm(1, lower=((20 - input$meant2)/sqrt(usedvar)), upper=((250 - input$meant2)/sqrt(usedvar)))
  
  while (length(data) < input$n2) {
    sample <- rtnorm(1, lower=((20 - input$meant2)/sqrt(usedvar)), upper=((250 - input$meant2)/sqrt(usedvar)))
    data_copy = c(data, sample)
    data_copy_scaled = input$meant2 + sqrt(usedvar) * scale(data_copy)
  
  if (min(data_copy_scaled) >= 20 & max(data_copy_scaled) <= 250) {
      data = c(data, sample)}}
      
  scaled_data <- as.numeric(input$meant2 + sqrt(usedvar) * scale(data))
  scaled_data}})
  
  
# ----------------------------------------------------
# Notifications when distributions were constructed
# ----------------------------------------------------
  
  observeEvent(input$construct_prior, {
    
    ids <- character(0)
    # Save the ID for removal later
    id <- showNotification(paste("Prior constructed successfully"), duration = 5, type="message")
    ids <<- c(ids, id)})
  
  observeEvent(input$construct_data,{
    ids <- character(0)
    # Save the ID for removal later
    id <- showNotification(paste("Dataset and likelihood constructed successfully"), duration = 5, type="message")
    ids <<- c(ids, id)})
    
  observeEvent(input$generate, {
    ids <- character(0)
    # Save the ID for removal later
    id <- showNotification(paste("Dataset and likelihood constructed successfully"), duration = 5, type="message")
    ids <<- c(ids, id)})
  
  observeEvent(input$run, {
    ids <- character(0)
    # Save the ID for removal later
    id <- showNotification(paste("Posterior will be constructed"), duration = 5, type="message")
    ids <<- c(ids, id)})
  
  
# ------------------
# Construct Plot
# ------------------

  observeEvent(input$run, { 
  
  output$hist <- renderPlot({
   
    input$run
    
    isolate({
    
    if (is.null(data())){
    likeli <- gendata()
    mean_d <- mean(likeli)
    sd_e <- sd(likeli)/sqrt(length(likeli)) 
    
    if (input$meant2 > 55 & input$meant2 < 165){
    likeli <- dtnorm(seq(0,200, length=1000),mean_d, sd_e, lower=40, upper=180)
    
    } else {
      
    likeli <- dtnorm(seq(0,200, length=1000),mean_d, sd_e, lower=0, upper=250) 
    }}   
    

    else{ likeli <- data()
    mean_d <- mean(likeli)
    sd_e <- sd(likeli)/sqrt(length(likeli)) 
    likeli <- dnorm(seq(0,200, length=1000),mean_d, sd_e)}

    
    if (input$prior == "runif") {
      
      xlim_min <- mean_d-2*sd_e
      xlim_max <-mean_d+2*sd_e
      
      
      
      # Derive posterior analytically
      library(msm)
      lower <- as.vector(seq(input$min,input$min, length=1000))
      upper <- as.vector(seq(input$max,input$max, length=1000))
      
      posterior2 <- dtnorm(seq(0,200, length=1000), mean(gendata()), sd(gendata())/sqrt(length(gendata())), lower=input$min, upper=input$max)
      
      plot(seq(0,200, length=1000), dunif(seq(0,200, length=1000),input$min, input$max), 
             xlim=c(xlim_min,xlim_max),
             ylim=c(0,max(posterior2, likeli)),
             main = "Bayesian Inference", lwd=3, type="l",col="dodgerblue",
             ylab = "Density", xlab = "")
        lines(seq(0,200, length=1000),likeli, col="chartreuse", lwd=3)
        lines(seq(0,200, length=1000),posterior2, col="red", lwd=2)
        clip(0,200,0,max(posterior2))
        abline(v=mean(posterior2), col="red", lwd=3, lty = 2)
        clip(0,200,0,max(likeli))
        abline(v=mean(mean_d), col="chartreuse", lwd=3, lty=2)
        legend(x="topright", legend=c("Prior","Likelihood","Posterior"),
               lty=c(1,1,1), lwd=3, col=c("dodgerblue", "chartreuse", "Red"),
               cex=1.5)
        
      
      
    }
    else if (input$prior == "trnorm") {
     
     
      
      
      
      
      priord <- dnorm(seq(0,200, length=1000), input$meant, sqrt(input$vart))
      ubound2 <- 1000/200*input$ubound
      lbound2 <- 1000/200*input$lbound
      priord[ubound2:length(priord)] = 0
      priord[1:lbound2] = 0
      
      posterior_mean <- (input$meant/input$vart + mean_d/(sd(gendata())^2/length(gendata()))) / (1/input$vart + 1/(sd(gendata())^2/length(gendata())))
      posterior_var <- 1/(1/input$vart + (1/(sd(gendata())^2/length(gendata()))))
      posterior <- dtnorm(seq(0,200, length=1000), mean=posterior_mean,sd=sqrt(posterior_var), lower=input$lbound, upper=input$ubound)
      
      
      lbound <- round(posterior_mean-1.96*sqrt(posterior_var), digits=2)
      ubound <- round(posterior_mean+1.96*sqrt(posterior_var), digits=2)
      
      xlim_min <- min(lbound, input$meant-6*sqrt(input$vart), mean_d-6*sd_e)
      xlim_max <- max(ubound, input$meant+6*sqrt(input$vart), mean_d+6*sd_e)
      
      
      
        
        plot(seq(0,200, length=1000), priord, 
             xlim=c(xlim_min,xlim_max),
             ylim=c(0,max(posterior, likeli, 
                          priord)),
             main = "Bayesian Inference", lwd=3, type="l", col="dodgerblue",
             ylab = "Density", xlab = "")
        lines(seq(0,200, length=1000),likeli, col="chartreuse", lwd=3)
        lines(seq(0,200, length=1000),posterior, col="red", lwd=3)
        clip(0,200,0,max(posterior))
        abline(v=posterior_mean, col="red", lwd=3, lty=2)
        clip(0,200,0,max(likeli))
        abline(v=mean(mean_d), col="chartreuse", lwd=3, lty=2)
        clip(0,200,0,max(priord))
        abline(v=input$meant, col="dodgerblue", lwd=3, lty=2)
        clip(0,200,0,1)
        legend(x="topright", legend=c("Prior","Likelihood","Posterior"),
               lty=c(1,1,1), lwd=3, col=c("dodgerblue", "chartreuse", "Red"),
               cex=1.5) 
        
      
    } 
    })
    })
  
  
  }) # end observe event input$run
  
  
  
  
  
  
  
  observeEvent(input$runsigmaunknown, { 
    
    output$hist <- renderPlot({
      
      input$run
      
      isolate({
        
        if (is.null(data())){
          likeli <- gendata()
          mean_d <- mean(likeli)
          sd_e <- sd(likeli)/sqrt(length(likeli)) 
          
          if (input$meant2 > 55 & input$meant2 < 165){
            likeli <- dtnorm(seq(0,200, length=1000),mean_d, sd_e, lower=40, upper=180)
            
          } else {
            
            likeli <- dtnorm(seq(0,200, length=1000),mean_d, sd_e, lower=0, upper=250) 
          }}   
        
        
        else{ likeli <- data()
        mean_d <- mean(likeli)
        sd_e <- sd(likeli)/sqrt(length(likeli)) 
        likeli <- dnorm(seq(0,200, length=1000),mean_d, sd_e)}
        
        
        if (input$prior == "runif") {
          
          xlim_min <- mean_d-2*sd_e
          xlim_max <-mean_d+2*sd_e
          
          
          
         
            
            posterior <<- eventReactive(input$run, {
              y <- gendata()
              distribution <- c("dnorm(mu,tau)T(", input$lbound2, ",", input$ubound2, ")")    
              model_string <- paste(c("model{
                                      for(i in 1:length(y)) {
                                      y[i] ~", distribution, 
                                      "}
                                      mu ~ dunif(", input$min,",", input$max,")
                                      sigma ~ dlnorm(0, 0.0625)
                                      tau <- 1 / pow(sigma, 2)}" , 
                                      sep=""))
              
              model <- jags.model(textConnection(model_string), data = list(y = y), n.chains = 1, n.adapt= 1000)
              update(model, 1000);
              mcmc_samples <- coda.samples(model, variable.names=c("mu"), n.iter=2000)
              mcmc_samples <<- unlist(mcmc_samples)
              
            })
            
            plot(seq(0,200, length=1000), dunif(seq(0,200, length=1000),input$min, input$max), 
                 xlim=c(xlim_min,xlim_max),
                 ylim=c(0,max(density(posterior())$y, likeli)),
                 main = "Bayesian Inference", lwd=3, type="l",col="dodgerblue",
                 ylab = "Density", xlab = "")
            lines(seq(0,200, length=1000),likeli, col="chartreuse", lwd=3)
            lines(density(posterior()), col="red", lwd=3)
            clip(0,200,0,max(posterior()))
            abline(v=mean(posterior()), col="red", lwd=3, lty = 2)
            clip(0,200,0,max(likeli))
            abline(v=mean(mean_d), col="chartreuse", lwd=3, lty=2)
            legend(x="topright", legend=c("Prior","Likelihood","Posterior"),
                   lty=c(1,1,1), lwd=3, col=c("dodgerblue", "chartreuse", "Red"),
                   cex=1.5)
            
            
            
     
    }
        else if (input$prior == "trnorm") {
          
          
              posterior <<- eventReactive(input$run, {
              y <- gendata()
              distribution <- c("dnorm(mu,tau)T(", 0, ",", 180, ")")    
              model_string <- paste(c("model{
                                      for(i in 1:length(y)) {
                                      y[i] ~", distribution, 
                                      "}
                                      mu ~ dnorm(", input$meant,", 1/", input$vart,") T(", input$lbound, ",",input$ubound,")
                                      sigma ~ dlnorm(0, 0.0625)
                                      tau <- 1 / pow(sigma, 2)}" , sep=""))
              
              model <- jags.model(textConnection(model_string), data = list(y = y), n.chains = 1, n.adapt= 1000)
              update(model, 1000);
              mcmc_samples <- coda.samples(model, variable.names=c("mu"), n.iter=2000)
              mcmc_samples <<- unlist(mcmc_samples)
              
            })
            
            
            priord <- dnorm(seq(0,200, length=1000), input$meant, sqrt(input$vart))
            ubound2 <- 1000/200*input$ubound
            lbound2 <- 1000/200*input$lbound
            priord[ubound2:length(priord)] = 0
            priord[1:lbound2] = 0
            
            # Just for zooming in/out
            posterior_mean <- (input$meant/input$vart + mean_d/(sd(gendata())^2/length(gendata()))) / (1/input$vart + 1/(sd(gendata())^2/length(gendata())))
            posterior_var <- 1/(1/input$vart + (1/(sd(gendata())^2/length(gendata()))))
            posterior2 <- dtnorm(seq(0,200, length=1000), mean=posterior_mean,sd=sqrt(posterior_var), lower=input$lbound, upper=input$ubound)
            
            
            lbound <- round(posterior_mean-1.96*sqrt(posterior_var), digits=2)
            ubound <- round(posterior_mean+1.96*sqrt(posterior_var), digits=2)
            
            xlim_min <- min(lbound, input$meant-6*sqrt(input$vart), mean_d-6*sd_e)
            xlim_max <- max(ubound, input$meant+6*sqrt(input$vart), mean_d+6*sd_e)
            
            
            plot(seq(0,200, length=1000), priord, 
                 xlim=c(xlim_min,xlim_max),
                 ylim=c(0,max(density(posterior())$y, likeli, 
                              priord)),
                 main = "Bayesian Inference", lwd=3, type="l", col="dodgerblue",
                 ylab = "Density", xlab = "")
            lines(seq(0,200, length=1000),likeli, col="chartreuse", lwd=3)
            lines(density(posterior()), col="red", lwd=3)
            clip(0,200,0,max(posterior()))
            abline(v=mean(posterior()), col="red", lwd=3, lty=2)
            clip(0,200,0,max(likeli))
            abline(v=mean(mean_d), col="chartreuse", lwd=3, lty=2)
            clip(0,200,0,max(priord))
            abline(v=input$meant, col="dodgerblue", lwd=3, lty=2)
            clip(0,200,0,1)
            legend(x="topright", legend=c("Prior","Likelihood","Posterior"),
                   lty=c(1,1,1), lwd=3, col=c("dodgerblue", "chartreuse", "Red"),
                   cex=1.5) 
            
            
            
     
  } 
    })
  })
    
    
}) # end observe event input$runsigmaunknown
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
#---------------------------
# Construct Summary Table
# ---------------------------  
  
  observeEvent(input$run, { 
  
  output$tbl <- renderTable({ 
    
    input$run
    
    if (is.null(data())){
      likeli <- gendata()} 
    else{ likeli <- data()}
    
    
    mean_d <- mean(likeli)
    sd_e <- sd(likeli)/sqrt(length(likeli))
    
    likeli <- dnorm(seq(0,200, length=1000),mean_d, sd_e)
    
    # Define Table for Results
    results.table <- matrix(nrow=4, ncol=5)
    colnames <- c("Mean", "Variance", "95% Lower Bound", "95% Upper Bound", "Calculation")
    rownames <- c("Prior", "Data", "Likelihood", "Posterior")
    colnames(results.table) <- colnames
    rownames(results.table) <- rownames
    
    
    if (input$prior == "runif"){
      
    # Derive posterior analytically
    library(msm)
    lower <- as.vector(seq(input$min,input$min, length=1000))
    upper <- as.vector(seq(input$max,input$max, length=1000))
    
    # just use dtnorm for likelihood as well
    
    posterior2 <- dtnorm(seq(0,200, length=1000), mean(gendata()), sd(gendata())/sqrt(length(gendata())), lower=input$min, upper=input$max)
      
    
    
      
      # Define Entries
      results.table[1,3] <- input$min+0.025*(input$max-input$min)
      results.table[1,4] <- input$min+0.975*(input$max-input$min)
      results.table[2,1] <- input$meant2
      results.table[2,2] <- input$vart2^2
      results.table[2,3] <- input$meant2-1.96*input$vart2
      results.table[2,4] <- input$meant2+1.96*input$vart2
      results.table[3,1] <- mean_d
      results.table[3,2] <- sd_e^2
      results.table[3,3] <- mean_d-1.96*sd_e
      results.table[3,4] <- mean_d+1.96*sd_e
      results.table[4,1] <- mean_d
      results.table[4,2] <- sd_e^2
      results.table[4,3] <- mean_d-1.96*sd_e
      results.table[4,4] <- mean_d+1.96*sd_e
      results.table <- round(results.table, digits=2)
      results.table[1,1] <- "N/A"
      results.table[1,2] <- "N/A"
      results.table[1,5] <- "Based on input values"
      results.table[2,5] <- "Based on exact simulation (frequentist)"
      results.table[3,5] <- "Based on exact simulation (frequentist)"
      results.table[4,5] <- "Based on analytical derivation (Bayesian)"
      
      results.table
      
    
    
    
  } else if (input$prior == "trnorm"){
    
   
   
    
    posterior_mean <- (input$meant/input$vart + mean_d/(sd(gendata())^2/length(gendata()))) / (1/input$vart + 1/(sd(gendata())^2/length(gendata())))
    posterior_var <- 1/(1/input$vart + (1/(sd(gendata())^2/length(gendata()))))
    posterior2 <- dtnorm(seq(0,200, length=1000), mean=posterior_mean,sd=sqrt(posterior_var), lower=input$lbound, upper=input$ubound)
    
    # Define Entries
    results.table[1,1] <- input$meant
    results.table[1,2] <- input$vart
    results.table[1,3] <- max((input$meant-1.96*sqrt(input$vart)),input$lbound)
    results.table[1,4] <- input$meant+1.96*sqrt(input$vart)
    results.table[2,1] <- input$meant2
    results.table[2,2] <- input$vart2^2
    results.table[2,3] <- input$meant2-1.96*input$vart2
    results.table[2,4] <- input$meant2+1.96*input$vart2
    results.table[3,1] <- mean_d
    results.table[3,2] <- sd_e^2
    results.table[3,3] <- mean_d-1.96*sd_e
    results.table[3,4] <- mean_d+1.96*sd_e
    results.table[4,1] <- posterior_mean
    results.table[4,2] <- posterior_var
    results.table[4,3] <- posterior_mean-1.96*sqrt(posterior_var)
    results.table[4,4] <- posterior_mean+1.96*sqrt(posterior_var) 
    results.table <- round(results.table, digits=2)
    results.table[1,5] <- "Based on input values"
    results.table[2,5] <- "Based on exact simulation (frequentist)"
    results.table[3,5] <- "Based on exact simulation (frequentist)"
    results.table[4,5] <- "Based on analytical derivation (Bayesian)"
    
    results.table 
    
  }}, include.rownames=TRUE)
  
  
  }) # end observe event input$run







observeEvent(input$runsigmaunknown, { 
  
  output$tbl <- renderTable({ 
    
    input$run
    
    if (is.null(data())){
      likeli <- gendata()} 
    else{ likeli <- data()}
    
    
    mean_d <- mean(likeli)
    sd_e <- sd(likeli)/sqrt(length(likeli))
    
    likeli <- dnorm(seq(0,200, length=1000),mean_d, sd_e)
    
    # Define Table for Results
    results.table <- matrix(nrow=4, ncol=5)
    colnames <- c("Mean", "Variance", "95% Lower Bound", "95% Upper Bound", "Calculation")
    rownames <- c("Prior", "Data", "Likelihood", "Posterior")
    colnames(results.table) <- colnames
    rownames(results.table) <- rownames
    
    
    if (input$prior == "runif"){
      
      # Derive posterior analytically
      library(msm)
      lower <- as.vector(seq(input$min,input$min, length=1000))
      upper <- as.vector(seq(input$max,input$max, length=1000))
      
      # just use dtnorm for likelihood as well
      
      posterior2 <- dtnorm(seq(0,200, length=1000), mean(gendata()), sd(gendata())/sqrt(length(gendata())), lower=input$min, upper=input$max)
      
      
     
        
        #y <- gendata()
        #distribution <- c("dnorm(mu,tau)T(", input$lbound2, ",", input$ubound2, ")")    
        # model_string <- paste(c("model{
        #    for(i in 1:length(y)) {
        #      y[i] ~", distribution, 
        #                        "}
        #   mu ~ dunif(", input$min,",", input$max,")
        #  sigma ~ dlnorm(0, 0.0625)
        #  tau <- 1 / pow(sigma, 2)}" , 
        #    sep=""))
        
        # model <- jags.model(textConnection(model_string), data = list(y = y), n.chains = 1, n.adapt= 1000)
        # update(model, 1000);
        #mcmc_samples <- coda.samples(model, variable.names=c("mu"), n.iter=2000)
        # mcmc_samples <- unlist(mcmc_samples)
        
        
        rownames <- c("Prior", "Data", "Likelihood", "Posterior")
        rownames(results.table) <- rownames
        
        
        # Define Entries
        results.table[1,3] <- input$min+0.025*(input$max-input$min)
        results.table[1,4] <- input$min+0.975*(input$max-input$min)
        results.table[2,1] <- input$meant2
        results.table[2,2] <- input$vart2^2
        results.table[2,3] <- input$meant2-1.96*input$vart2
        results.table[2,4] <- input$meant2+1.96*input$vart2
        results.table[3,1] <- mean_d
        results.table[3,2] <- sd_e^2
        results.table[3,3] <- mean_d-1.96*sd_e
        results.table[3,4] <- mean_d+1.96*sd_e
        results.table[4,1] <- mean(mcmc_samples)
        results.table[4,2] <- var(posterior())
        results.table[4,3] <- quantile(mcmc_samples, 0.025)
        results.table[4,4] <- quantile(mcmc_samples, 0.975)
        results.table <- round(results.table, digits=2)
        results.table[1,1] <- "N/A"
        results.table[1,2] <- "N/A"
        results.table[1,5] <- "Based on input values"
        results.table[2,5] <- "Based on exact simulation (frequentist)"
        results.table[3,5] <- "Based on exact simulation (frequentist)"
        results.table[4,5] <- "Based on empirical simulation (Bayesian)"
        
        results.table 
      
    } else if (input$prior == "trnorm"){
      
      
      
        #  posterior <- eventReactive(input$run, {
        #   y <- gendata()
        #  distribution <- c("dnorm(mu,tau)T(", 40, ",", 180, ")")    
        #   model_string <- paste(c("model{
        #                          for(i in 1:length(y)) {
        #                          y[i] ~", distribution, 
        #                          "}
        #                          mu ~ dnorm(", input$meant,", 1/", sqrt(input$vart),"^2) T(", input$lbound, ",",input$ubound,")
        #                          sigma ~ dlnorm(0, 0.0625)
        #                          tau <- 1 / pow(sigma, 2)}" , sep=""))
        
        # model <- jags.model(textConnection(model_string), data = list(y = y), n.chains = 1, n.adapt= 1000)
        # update(model, 1000);
        # mcmc_samples <- coda.samples(model, variable.names=c("mu"), n.iter=2000)
        
        # mcmc_samples <- unlist(mcmc_samples)
        # })
        
        # Define Entries
        results.table[1,1] <- input$meant
        results.table[1,2] <- input$vart
        results.table[1,3] <- max((input$meant-1.96*sqrt(input$vart)),input$lbound)
        results.table[1,4] <- input$meant+1.96*sqrt(input$vart)
        results.table[2,1] <- input$meant2
        results.table[2,2] <- input$vart2^2
        results.table[2,3] <- input$meant2-1.96*input$vart2
        results.table[2,4] <- input$meant2+1.96*input$vart2
        results.table[3,1] <- mean_d
        results.table[3,2] <- sd_e^2
        results.table[3,3] <- mean_d-1.96*sd_e
        results.table[3,4] <- mean_d+1.96*sd_e
        results.table[4,1] <- mean(mcmc_samples)
        results.table[4,2] <- var(posterior())
        results.table[4,3] <- quantile(mcmc_samples, 0.025)
        results.table[4,4] <- quantile(mcmc_samples, 0.975)
        results.table <- round(results.table, digits=2)
        results.table[1,5] <- "Based on input values"
        results.table[2,5] <- "Based on exact simulation (frequentist)"
        results.table[3,5] <- "Based on exact simulation (frequentist)"
        results.table[4,5] <- "Based on empirical simulation (Bayesian)"
        
        results.table
       
     
      
    }}, include.rownames=TRUE)


}) # end observe event input$runsigmaunknown

}