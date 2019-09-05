##############################
# Prior plots                #
##############################

# X-axis range
x1 <- seq(1, 5, length.out = 1000)
x2 <- seq(18, 22, length.out = 1000)

# Priors
prior1 <- dnorm(x1, 3, sd=0.4)
prior2 <- dnorm(x1, 3, sd=1000)
prior3 <- dnorm(x2, 20, sd=0.4)
prior4 <- dnorm(x2, 20, sd=1000)

# Plots
par(mfrow=c(2,2))
plot(x1, prior1, type= "l", ylab = "Likelihood", ylim = c(0,1), col= "red", lwd=3, main= "N(3, 0.4)", xlab= "x")
plot(x1, prior2, type= "l", ylab = "Likelihood", ylim = c(0,1), col= "red", lwd=3, main= "N(3, 1000)", xlab= "x")

plot(x2, prior3, type= "l", ylab = "Likelihood", ylim = c(0,1), col= "red", lwd=3, main= "N(20, 0.4)", xlab= "x")
plot(x2, prior4, type= "l", ylab = "Likelihood", ylim = c(0,1), col= "red", lwd=3, main= "N(20, 1000)", xlab= "x")
