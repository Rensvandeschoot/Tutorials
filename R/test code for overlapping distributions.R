set.seed(11)
d <- data.frame(f=c(rep("a", 50), rep("b", 60)), x=c(rnorm(50), runif(60, 0, 3)))
ddply(d, .(f), summarize,ql=quantile(x, .1741),qu=quantile(x, .8259))
https://stats.stackexchange.com/questions/122857/how-to-determine-overlap-of-two-empirical-distribution-based-on-quantiles

f1<- rnorm(50)
f2 <- runif(60, 0, 3)



overlap <- function(x, y) {
  F.x <- ecdf(x); F.y <- ecdf(y)
  z <- uniroot(function(z) F.x(z) + F.y(z) - 1, interval<-c(min(c(x,y)), max(c(x,y))))
  return(list(Root=z, F.x=F.x, F.y=F.y))
}

ecdf(f1)


# simulate two samples
a <- rnorm(100, 2)
b <- rnorm(2000000, 2)

# define limits of a common grid, adding a buffer so that tails aren't cut off
lower <- min(c(a, b)) - 1 
upper <- max(c(a, b)) + 1

# generate kernel densities
da <- density(a, from=lower, to=upper)
db <- density(b, from=lower, to=upper)
d <- data.frame(x=da$x, a=da$y, b=db$y)

# calculate intersection densities
d$w <- pmin(d$a, d$b)

# integrate areas under curves
library(sfsmisc)
total <- integrate.xy(d$x, d$a) + integrate.xy(d$x, d$b)
intersection <- integrate.xy(d$x, d$w)

# compute overlap coefficient
overlap <- 2 * intersection / total


#https://stats.stackexchange.com/questions/97596/how-to-calculate-overlap-between-empirical-probability-densities