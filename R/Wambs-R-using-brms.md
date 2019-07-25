---
title: "WAMBS R Tutorial (using brms)"
author: "By [Laurent Smeets](https://www.rensvandeschoot.com/colleagues/laurent-smeets/) and [Rens van de Schoot](https://www.rensvandeschoot.com/about-rens/)"
date: 'Last modified: 25 July 2019'
output:
  html_document:
    keep_md: true
---




In this tutorial you follow the steps of the When-to-Worry-and-How-to-Avoid-the-Misuse-of-Bayesian-Statistics - checklist [(the WAMBS-checklist)](https://www.rensvandeschoot.com/wambs-checklist/)

  <p>&nbsp;</p>

## Preparation

This tutorial expects:

- Installation of [STAN](https://mc-stan.org/users/interfaces/rstan) and [Rtools](https://cran.r-project.org/bin/windows/Rtools). For more information please see https://github.com/stan-dev/rstan/wiki/RStan-Getting-Started
- Installation of R packages `rstan`, and `brms`. This tutorial was made using brms version 2.8.0 in R version 3.6.0
- Basic knowledge of hypothesis testing
- Basic knowledge of correlation and regression
- Basic knowledge of [Bayesian](https://www.rensvandeschoot.com/a-gentle-introduction-to-bayesian-analysis-applications-to-developmental-research/) inference
- Basic knowledge of coding in R



[expand title="Check the WAMBS checklist here" trigclass="noarrow my_button" targclass="my_content" tag="button"]


## **WAMBS checklist** 

### *When to worry, and how to Avoid the Misuse of Bayesian Statistics*

**To be checked before estimating the model**

1. Do you understand the priors?

**To be checked after estimation but before inspecting model results**

2.    Does the trace-plot exhibit convergence?
3.  Does convergence remain after doubling the number of iterations?
4.   Does the posterior distribution histogram have enough information?
5.   Do the chains exhibit a strong degree of autocorrelation?
6.   Do the posterior distributions make substantive sense?

**Understanding the exact influence of the priors**

7. Do different specification of the multivariate variance priors influence the results?
8.   Is there a notable effect of the prior when compared with non-informative priors?
9.   Are the results stable from a sensitivity analysis?
10.   Is the Bayesian way of interpreting and reporting model results used?

[/expand]

  <p>&nbsp;</p>


## **Example Data**


The data we be use for this exercise is based on a study about predicting PhD-delays ([Van de Schoot, Yerkes, Mouw and Sonneveld 2013](http://journals.plos.org/plosone/article?id=10.1371/journal.pone.0068839)).  The data can be downloaded [here](https://www.rensvandeschoot.com/wp-content/uploads/2018/10/phd-delays.csv). Among many other questions, the researchers asked the Ph.D. recipients how long it took them to finish their Ph.D. thesis (n=333). It appeared that Ph.D. recipients took an average of 59.8 months (five years and four months) to complete their Ph.D. trajectory. The variable B3_difference_extra measures the difference between planned and actual project time in months (mean=9.96, minimum=-31, maximum=91, sd=14.43). For more information on the sample, instruments, methodology and research context we refer the interested reader to the paper.

For the current exercise we are interested in the question whether age (M = 30.7, SD = 4.48, min-max = 26-69) of the Ph.D. recipients is related to a delay in their project.

The relation between completion time and age is expected to be non-linear. This might be due to that at a certain point in your life (i.e., mid thirties), family life takes up more of your time than when you are in your twenties or when you are older.

So, in our model the gap (*B3_difference_extra*) is the dependent variable and age (*E22_Age*) and age$^2$(*E22_Age_Squared *) are the predictors. The data can be found in the file <span style="color:red"> ` phd-delays.csv` </span>.

  <p>&nbsp;</p>

##### _**Question:** Write down the null and alternative hypotheses that represent this question. Which hypothesis do you deem more likely?_

[expand title="Answer" trigclass="noarrow my_button" targclass="my_content" tag="button"]

$H_0:$ _$age$ is not related to a delay in the PhD projects._

$H_1:$ _$age$ is related to a delay in the PhD projects._ 

$H_0:$ _$age^2$ is not related to a delay in the PhD projects._

$H_1:$ _$age^2$ is related to a delay in the PhD projects._ 

[/expand]


  <p>&nbsp;</p>

## Preparation - Importing and Exploring Data



```r
# if you dont have these packages installed yet, please use the install.packages("package_name") command.
library(rstan) 
library(brms)
library(psych) #to get some extended summary statistics
library(tidyverse) # needed for data manipulation and plotting 
library(bayesplot) #  needed for plotting 
library(ggmcmc)
library(mcmcplots) 
library(tidybayes)
```

You can find the data in the file <span style="color:red"> ` phd-delays.csv` </span>, which contains all variables that you need for this analysis. Although it is a .csv-file, you can directly load it into R using the following syntax:

```r
#read in data
dataPHD <- read.csv2(file="phd-delays.csv")
colnames(dataPHD) <- c("diff", "child", "sex","age","age2")
```


Alternatively, you can directly download them from GitHub into your R work space using the following command:

```r
dataPHD <- read.csv2(file="https://raw.githubusercontent.com/LaurentSmeets/Tutorials/master/Blavaan/phd-delays.csv")
colnames(dataPHD) <- c("diff", "child", "sex","age","age2")
```

GitHub is a platform that allows researchers and developers to share code, software and research and to collaborate on projects (see https://github.com/)

Once you loaded in your data, it is advisable to check whether your data import worked well. Therefore, first have a look at the summary statistics of your data. you can do this by using the  `describe()` function.
  
  
  <p>&nbsp;</p>
  
##### _**Question:** Have all your data been loaded in correctly? That is, do all data points substantively make sense? If you are unsure, go back to the .csv-file to inspect the raw data._

[expand title="Answer" trigclass="noarrow my_button" targclass="my_content" tag="button"]

[expand title="Answer" trigclass="noarrow my_button" targclass="my_content" tag="button"]


```r
describe(dataPHD)
```

```
##       vars   n    mean     sd median trimmed    mad min  max range  skew
## diff     1 333    9.97  14.43      5    6.91   7.41 -31   91   122  2.21
## child    2 333    0.18   0.38      0    0.10   0.00   0    1     1  1.66
## sex      3 333    0.52   0.50      1    0.52   0.00   0    1     1 -0.08
## age      4 333   31.68   6.86     30   30.39   2.97  26   80    54  4.45
## age2     5 333 1050.22 656.39    900  928.29 171.98 676 6400  5724  6.03
##       kurtosis    se
## diff      5.92  0.79
## child     0.75  0.02
## sex      -2.00  0.03
## age      24.99  0.38
## age2     42.21 35.97
```

_The descriptive statistics make sense:_

_diff: Mean (9.97), SE (0.79)_

_age: Mean (31.68), SE (0.38)_

_age2: Mean (1050.22), SE (35.97)_

[/expand]

  <p>&nbsp;</p>

##   **Step 1: Do you understand the priors?**

  <p>&nbsp;</p>
  
### 1.Do you understand the priors?


Before actually looking at the data we first need to think about the prior distributions and hyperparameters for our model. For the current model, there are four priors:

- the intercept
- the two regression parameters ($\beta_1$ for the relation with AGE and $\beta_2$ for the relation with AGE2)
- the residual variance ($\in$)

We first need to determine which distribution to use for the priors. Let&#39;s use for the

- intercept a normal prior with $\mathcal{N}(\mu_0, \sigma^{2}_{0})$, where $\mu_0$ is the prior mean of the distribution and $\sigma^{2}_{0}$ is the variance parameter
- $\beta_1$ a normal prior with $\mathcal{N}(\mu_1, \sigma^{2}_{1})$
- $\beta_2$ a normal prior with $\mathcal{N}(\mu_2, \sigma^{2}_{2})$
- $\in$ an Inverse Gamma distribution with $IG(\kappa_0,\theta_0)$, where $\kappa_0$ is the shape parameter of the distribution and $\theta_0$ the rate parameter

Next, we need to specify actual values for the hyperparameters of the prior distributions. Let&#39;s say we found a previous study and based on this study the following hyperparameters can be specified:

- intercept $\sim \mathcal{N}(-35, 20)$
- $\beta_1 \sim \mathcal{N}(.8, 5)$
- $\beta_2 \sim \mathcal{N}(0, 10)$
- $\in \sim IG(.5, .5)$ This is an uninformative prior for the residual variance, which has been found to preform well in simulation studies.

It is a good idea to plot these distribution to see how they look. To do so, one easy way is to sample a lot of values from one of these distributions and make a density plot out of it, see the code below. Replace the 'XX' with the values of the hyperparameters.


```r
par(mfrow = c(2,2))
plot(density(rnorm(n = 100000, mean = XX, sd = sqrt(XX))), main = "prior intercept") # the rnorm function uses the standard devation instead of variance, that is why we use the sqrt
plot(density(rnorm(n = 100000, mean = XX, sd = sqrt(XX))), main = "effect Age")
plot(density(rnorm(n = 100000, mean = XX, sd = sqrt(XX))), main = "effect Age^2")
```


[expand title="Answer" trigclass="noarrow my_button" targclass="my_content" tag="button"]



```r
par(mfrow = c(2,2))
plot(density(rnorm(n = 100000, mean = -35, sd = sqrt(20))), main = "prior intercept") # the rnorm function uses the standard devation instead of variance, that is why we use the sqrt
plot(density(rnorm(n = 100000, mean = .8,  sd = sqrt(5))),   main = "effect Age")
plot(density(rnorm(n = 100000, mean = 0,   sd = sqrt(10))),  main = "effect Age^2")
```

![](Wambs-R-using-brms_files/figure-html/unnamed-chunk-7-1.png)<!-- -->
[/expand]

We can also plot what the our expected delay would be (like we did in the brms regression assignment) given these priors. With these priors the regression formula would be: $delay=-35+ .8*age + 0*age^2$. These are just the means of the priors and do not yet qualify the different levels of uncertainty. Replace the 'XX' in the following code with the prior means.


```r
years <- 20:80
delay <- XX + XX*years + XX*years^2
plot(years, delay, type = "l")
```


[expand title="Answer" trigclass="noarrow my_button" targclass="my_content" tag="button"]



```r
years <- 20:80
delay <- -35 + .8*years + 0*years^2
plot(years, delay, type= "l")
```
[/expand]


```r
years <- 20:80
delay <- -35 + .8*years + 0*years^2
plot(years, delay, type =  "l")
```

![](Wambs-R-using-brms_files/figure-html/unnamed-chunk-10-1.png)<!-- -->


  <p>&nbsp;</p>

##**Step 2: Run the model and check for convergence**


To run a multiple regression with brms, you first specify the model, then fit the model and finally acquire the summary (similar to the frequentist model using  `lm()`). The model is specified as follows:


1.  A dependent variable we want to predict.
2.  A "~", that we use to indicate that we now give the other variables of interest.
    (comparable to the '=' of the regression equation).
3.  The different independent variables separated by the summation symbol '+'.
4.  Finally, we insert that the dependent variable has a variance and that we
    want an intercept.  
5. We do set a seed to make the results exactly reproducible.
6. To specify priors, using the `set_prior()` function. Be careful, Stan uses standard deviations instead of variance in the normal distribution. The standard deviations is the square root of the variance, so a variance of 5 corresponds to a standard deviation of 2.24 and a variance of 10 corresponds to a standard deviation of 3.16.
7. to place a prior on the fixed intercept, one needs to include `0 + intercept`. See [here](https://rdrr.io/cran/brms/man/prior_samples.html) for an explanation.


There are many other options we can select, such as the number of chains how many iterations we want and how long of a warm-up phase we want, but we will just use the defaults for now.

For more information on the basics of brms, see the [website and vignettes](https://cran.r-project.org/web/packages/brms/index.html) 


### 2. Does the trace-plot exhibit convergence?

First we run the anlysis with only a short burnin period of 250 samples and then take another 500 samples.

The following code is how to specify the regression model:



```r
# 1) set the priors
priors_inf <- c(set_prior("normal(.8, 2.24)", class = "b", coef = "age"),
               set_prior("normal(0, 3.16)", class = "b", coef = "age2"),
               set_prior("normal(-35, 4.47)", class = "b", coef =  "intercept"),
                 set_prior("inv_gamma(.5,.5)", class = "sigma"))

# 2) specify the model
model_few_samples <- brm(formula = diff ~ 0 + intercept + age + age2, 
                         data    = dataPHD,
                         prior   = priors_inf,
                         warmup  = 250,
                         iter    = 500,
                         seed    = 12345)
```

Now we can plot the trace plots.


```r
modeltranformed <- ggs(model_few_samples) # the ggs function transforms the BRMS output into a longformat tibble, that we can use to make different types of plots.
ggplot(filter(modeltranformed, Parameter %in% c("b_intercept", "b_age", "b_age2", "sigma")),
       aes(x   = Iteration,
           y   = value, 
           col = as.factor(Chain)))+
  geom_line()+
  facet_grid(Parameter ~ .,
             scale     = 'free_y',
             switch    = 'y')+
  labs(title = "Trace plots",
       col   = "Chains") +
  theme_minimal()
```

![](Wambs-R-using-brms_files/figure-html/unnamed-chunk-12-1.png)<!-- -->


Alternatively, you can simply make use of the built-in plotting capabilities of Rstan.


```r
stanplot(model_few_samples, type = "trace")
```

```
## No divergences to plot.
```

![](Wambs-R-using-brms_files/figure-html/unnamed-chunk-13-1.png)<!-- -->


It seems like the trace (caterpillar) plots are not neatly converged into one each other (we ideally want one fat caterpillar, like the one for sigma). This  indicates we need more samples.

We can check if the chains convergenced by having a look at the convergence diagnostics. Two of these diagnostics of interest include the Gelman and Rubin diagnostic and the Geweke diagnostic. 

* The Gelman-Rubin Diagnostic shows the PSRF values (using the  within and between chain variability). You should look at the Upper CI/Upper limit, which are all should be close to 1. If they aren't close to 1, you should use more iterations. Note: The Gelman and Rubin diagnostic is also automatically given in the summary of brms under the column Rhat 
* The Geweke Diagnostic shows the z-scores for a test of equality of means between the first and last parts of each chain, which should be <1.96. A separate statistic is calculated for each variable in each chain. In this way it check whether a chain has stabalized. If this is not the case, you should increase the number of iterations. In the plots you should check how often values exceed the boundary lines of the z-scores. Scores above 1.96  or below -1.96 mean that the two portions of the chain significantly differ and full chain convergence was not obtained.


To obtain the Gelman and Rubin diagnostic use:



To obtain the Gelman and Rubin diagnostic use:

```r
modelposterior <- as.mcmc(model_few_samples) # with the as.mcmc() command we can use all the CODA package convergence statistics and plotting options
gelman.diag(modelposterior[, 1:4])
```

```
## Potential scale reduction factors:
## 
##             Point est. Upper C.I.
## b_intercept       3.92       6.76
## b_age             3.78       6.50
## b_age2            3.02       5.06
## sigma             1.04       1.11
## 
## Multivariate psrf
## 
## 3.3
```

```r
gelman.plot(modelposterior[, 1:4])
```

![](Wambs-R-using-brms_files/figure-html/unnamed-chunk-14-1.png)<!-- -->

To obtain the Geweke diagnostic use:

```r
geweke.diag(modelposterior[, 1:4])
```

```
## [[1]]
## 
## Fraction in 1st window = 0.1
## Fraction in 2nd window = 0.5 
## 
## b_intercept       b_age      b_age2       sigma 
##       5.334     -11.443       7.479       2.465 
## 
## 
## [[2]]
## 
## Fraction in 1st window = 0.1
## Fraction in 2nd window = 0.5 
## 
## b_intercept       b_age      b_age2       sigma 
##      -2.057       1.559      -1.456       1.105 
## 
## 
## [[3]]
## 
## Fraction in 1st window = 0.1
## Fraction in 2nd window = 0.5 
## 
## b_intercept       b_age      b_age2       sigma 
##     0.42201     0.08127    -0.60839    -0.25410 
## 
## 
## [[4]]
## 
## Fraction in 1st window = 0.1
## Fraction in 2nd window = 0.5 
## 
## b_intercept       b_age      b_age2       sigma 
##      0.3407     -0.1883     -0.4051      3.7839
```

```r
geweke.plot(modelposterior[, 1:4])
```

![](Wambs-R-using-brms_files/figure-html/unnamed-chunk-15-1.png)<!-- -->![](Wambs-R-using-brms_files/figure-html/unnamed-chunk-15-2.png)<!-- -->![](Wambs-R-using-brms_files/figure-html/unnamed-chunk-15-3.png)<!-- -->![](Wambs-R-using-brms_files/figure-html/unnamed-chunk-15-4.png)<!-- -->

These statistics confirm that the chains have not converged. Therefore, we run the same analysis with more samples.


```r
model <- brm(formula = diff ~ 0 + intercept + age + age2, 
             data    = dataPHD,
             prior   = priors_inf,
             warmup  = 2000,
             iter    = 4000,
             seed    = 12345)
```


Obtain the trace plots again.

```r
stanplot(model, type = "trace")
```

```
## No divergences to plot.
```

![](Wambs-R-using-brms_files/figure-html/unnamed-chunk-17-1.png)<!-- -->

Obtain the Gelman and Rubin diagnostic again.

```r
modelposterior <- as.mcmc(model) # with the as.mcmc() command we can use all the CODA package convergence statistics and plotting options
gelman.diag(modelposterior[, 1:4])
```

```
## Potential scale reduction factors:
## 
##             Point est. Upper C.I.
## b_intercept          1          1
## b_age                1          1
## b_age2               1          1
## sigma                1          1
## 
## Multivariate psrf
## 
## 1
```

```r
gelman.plot(modelposterior[, 1:4])
```

![](Wambs-R-using-brms_files/figure-html/unnamed-chunk-18-1.png)<!-- -->

Obtain Geweke diagnostic again.

```r
geweke.plot(modelposterior[, 1:4])
```

![](Wambs-R-using-brms_files/figure-html/unnamed-chunk-19-1.png)<!-- -->![](Wambs-R-using-brms_files/figure-html/unnamed-chunk-19-2.png)<!-- -->![](Wambs-R-using-brms_files/figure-html/unnamed-chunk-19-3.png)<!-- -->![](Wambs-R-using-brms_files/figure-html/unnamed-chunk-19-4.png)<!-- -->

Now we see that the Gelman and Rubin diagnostic (PRSF) is close to 1 for all parameters and the the Geweke diagnostic is not > 1.96.




### 3. Does convergence remain after doubling the number of iterations?

As is recommended in the WAMBS checklist, we double the amount of iterations to check for local convergence.


```r
model_doubleiter <- brm(formula = diff ~ 0 + intercept + age + age2, 
                        data    = dataPHD,
                        prior   = priors_inf,
                        warmup  = 4000,
                        iter    = 8000,
                        seed    = 12345)
```

You should again have a look at the above-mentioned convergence statistics, but we can also compute the relative bias to inspect if doubling the number of iterations influences the posterior parameter estimates ($bias= 100*\frac{(model \; with \; double \; iteration \; - \; initial \; converged \; model )}{initial \; converged \; model}$). In order to preserve clarity we  just calculate the bias of the two regression coefficients.

You should combine the relative bias in combination with substantive knowledge about the metric of the parameter of interest to determine when levels of relative deviation are negligible or problematic. For example, with a regression coefficient of 0.001, a 5% relative deviation level might not be substantively relevant. However, with an intercept parameter of 50, a 10% relative deviation level might be quite meaningful. The specific level of relative deviation should be interpreted in the substantive context of the model. Some examples of interpretations are:

- if relative deviation is &lt; |5|%, then do not worry;
- if relative deviation &gt; |5|%, then rerun with 4x nr of iterations.


_**Question:** calculate the relative bias. Are you satisfied with number of iterations, or do you want to re-run the model with even more iterations?_


[expand title="Answer" trigclass="noarrow my_button" targclass="my_content" tag="button"]


To get the relative bias simply save the means of the regression coefficients and other parameters (ignore `lp__` for now) for the two different analyses and compute the bias. 


```r
round(100*((posterior_summary(model_doubleiter)[,"Estimate"] - posterior_summary(model)[,"Estimate"]) / posterior_summary(model)[,"Estimate"]), 4)
```

```
## b_intercept       b_age      b_age2       sigma        lp__ 
##     -0.3279     -0.2810     -0.3135     -0.1298     -0.0033
```

_The relative bias is small enough (<5%) not worry about it._ 

[/expand]


  <p>&nbsp;</p>

### 4.   Does the posterior distribution histogram have enough information?

By having a look at the posterior distribution histogram `plot(fit.bayes, pars=1:4, plot.type="stan_hist")`, we can check if it has enough information. 

_**Question:** What can you conclude about distribution histograms?_

[expand title="Answer" trigclass="noarrow my_button" targclass="my_content" tag="button"]



```r
stanplot(model, type = "hist")
```

```
## `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.
```

![](Wambs-R-using-brms_files/figure-html/unnamed-chunk-22-1.png)<!-- -->

_The histograms look smooth and have no gaps or other abnormalities. Based on this, adding more iterations is not necessary. However, if you arenot satisfied, you can improve the number of iterations again. Posterior distributions do not have to be symmetrical, but in this example they seem to be._ 


If we compare this with histograms based on the first analysis (with very few iterations), this difference becomes clear:


```r
stanplot(model_few_samples, type = "hist")
```

```
## `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.
```

![](Wambs-R-using-brms_files/figure-html/unnamed-chunk-23-1.png)<!-- -->

[/expand]


  <p>&nbsp;</p>
  

### 5.   Do the chains exhibit a strong degree of autocorrelation?


To obtain information about autocorrelation the following syntax can be used:


```r
stanplot(model, pars = 1:4, type = "acf")
```

![](Wambs-R-using-brms_files/figure-html/unnamed-chunk-24-1.png)<!-- -->

_**Question:** What can you conclude about these autocorrelation plots?_

[expand title="Answer" trigclass="noarrow my_button" targclass="my_content" tag="button"]



_These results show that autocorrelation is quite stong after a few lags. This means it is important to make sure we ran the analysis with a lot of samples, because with a high autocorrelation it will take longer until the whole parameter space has been identified. For more informtation on autocorrelation check this [paper](https://besjournals.onlinelibrary.wiley.com/doi/full/10.1111/j.2041-210X.2011.00131.x)._

[/expand]



### 6.   Do the posterior distributions make substantive sense?

We plot the posterior distributions and see if they are unimodel (one peak), if they are clearly centered around one value, if they give a realistic estimate and if they make substantive sense compared to the our prior believes (priors). Here we plot the  posteriors of the regression coefficients. If you want you can also plot the mean and the 95% Posterior HPD Intervals.



```r
stanplot(model, pars = 1:4, type = "dens")
```

![](Wambs-R-using-brms_files/figure-html/unnamed-chunk-25-1.png)<!-- -->


_**Question:** What is your conclusion; do the posterior distributions make sense?_

[expand title="Answer" trigclass="noarrow my_button" targclass="my_content" tag="button"]


_Yes, we see a clear negative intercept, which makes sense since a value of age = 0 for Ph.D is impossible. We also have have plausible ranges of values for the regression coefficients and a positive variance._

[/expand]


## **step 3: Understanding the exact influence of the priors**


First we  check the results of the analysis with the priors we used so far.

```r
summary(model)
```

```
##  Family: gaussian 
##   Links: mu = identity; sigma = identity 
## Formula: diff ~ 0 + intercept + age + age2 
##    Data: dataPHD (Number of observations: 333) 
## Samples: 4 chains, each with iter = 4000; warmup = 2000; thin = 1;
##          total post-warmup samples = 8000
## 
## Population-Level Effects: 
##           Estimate Est.Error l-95% CI u-95% CI Eff.Sample Rhat
## intercept   -36.40      4.26   -44.66   -28.06       2409 1.00
## age           2.15      0.21     1.74     2.56       2288 1.00
## age2         -0.02      0.00    -0.03    -0.02       2662 1.00
## 
## Family Specific Parameters: 
##       Estimate Est.Error l-95% CI u-95% CI Eff.Sample Rhat
## sigma    14.04      0.55    13.01    15.15       3093 1.00
## 
## Samples were drawn using sampling(NUTS). For each parameter, Eff.Sample 
## is a crude measure of effective sample size, and Rhat is the potential 
## scale reduction factor on split chains (at convergence, Rhat = 1).
```


### 7. Do different specification of the variance priors influence the results?

So far we have used the -$\in \sim IG(.5, .5)$ prior, but we can also use the -$\in \sim IG(.01, .01)$ prior and see if doing so makes a difference. to quantify this difference we again calculate a relative bias.

_**Question:** Are the results robust for different specifications of the prior on the residual variance?_

| Parameters | Estimate with $\in \sim IG(.01, .01)$ | Estimate with $\in \sim IG(.5, .5)$ | Bias |
| --- | --- | --- | --- |
| Intercept | |  | |
| Age       | |  | |
| Age2      | |  | |
| Residual variance |  |  |  |


[expand title="Answer" trigclass="noarrow my_button" targclass="my_content" tag="button"]


```r
# 1) set the priors
priors_inf2 <- c(set_prior("normal(.8, 2.24)", class = "b", coef = "age"),
               set_prior("normal(0, 3.16)", class = "b", coef = "age2"),
               set_prior("normal(-35, 4.47)", class = "b", coef=  "intercept"),
               set_prior("inv_gamma(.01,.01)", class="sigma"))

# 2) specify the model
model.difIG <- brm(formula = diff ~ 0 + intercept + age + age2, 
                   data    = dataPHD,
                   prior   = priors_inf2,
                   warmup  = 2000,
                   iter    = 4000,
                   seed    = 12345)
```



```r
posterior_summary(model.difIG)
```

```
##                  Estimate   Est.Error          Q2.5         Q97.5
## b_intercept -3.622203e+01 4.223666351 -4.441874e+01 -2.785579e+01
## b_age        2.143473e+00 0.210379606  1.731300e+00  2.554017e+00
## b_age2      -2.065084e-02 0.002681358 -2.576232e-02 -1.542095e-02
## sigma        1.405130e+01 0.543962535  1.305633e+01  1.520437e+01
## lp__        -1.363654e+03 1.427742809 -1.367363e+03 -1.361893e+03
```





| Parameters        | Estimate with $\in \sim IG(.01, .01)$ | Estimate with $\in \sim IG(.5, .5)$ | Bias                                             |
| ---               | ---                                   | ---                                 | ---                                              |
| Intercept         | -36.222            |-36.398|$100\cdot \frac{-36.222--36.398 }{-36.398} = -0.48\%$ |
| Age               | 2.143              |2.152|$100\cdot \frac{2.143-2.152 }{2.152} = -0.38\%$ |
| Age2              | -0.021           |-0.021|$100\cdot \frac{-0.021--0.021 }{-0.021} = -0.32\%$ |
| Residual variance | 14.051           |14.041|$100\cdot \frac{14.051-14.041 }{14.041} = 0.07\%$ |

_Yes, the results are robust, because there is only a really small amount of relative bias for the residual variance._


[/expand]

  <p>&nbsp;</p>

### 8.   Is there a notable effect of the prior when compared with non-informative priors?



The default brms priors are non-informative, so we can run the analysis without any specified priors and compare them to the model we have run thus far, using the relative bias, to see if there is a large influence of the priors.

_**Question**: What is your conclusion about the influence of the priors on the posterior results?_

| Parameters | Estimates with default priors | Estimate with informative priors | Bias|
| --- | --- | --- | --- |
| Intercept |  |      |  |
| Age |  |  | |
| Age2 |  |  ||
| Residual variance | |  |  |

[expand title="Answer" trigclass="noarrow my_button" targclass="my_content" tag="button"]


From the brms manual we learn that:

1. *The default prior for population-level effects (including monotonic and category specific effects) is an improper flat prior over the reals."*
2. *"By default, sigma has a half student-t prior that scales in the same way as the group-level standard deviations."*

We can run the model without our priors and check if doing so strongly influences the results.


```r
model.default <- brm(formula = diff ~ 0 + intercept + age + age2, 
                     data    = dataPHD,
                     warmup  = 1000,
                     iter    = 2000,
                     seed    = 123)

posterior_summary(model.default)
```






| Parameters | Estimates with default priors | Estimate with informative priors | Bias|
| ---               | ---                                   | ---                                 | ---                                              |
| Intercept         | -46.96            |-36.4|$100\cdot \frac{-46.962--36.398 }{-36.398} = 29.03\%$ |
| Age               | 2.651              |2.152|$100\cdot \frac{2.651-2.152 }{2.152} = 23.19\%$ |
| Age2              | -0.026           |-0.021|$100\cdot \frac{-0.026--0.021 }{-0.021} = 24.19\%$ |
| Residual variance | 14.021           |14.041|$100\cdot \frac{14.021-14.041 }{14.041} = -0.15\%$ |

_The informative priors have quite some influence (up to 25%) on the posterior results of the regression coefficients. This is not a bad thing, just important to keep in mind._ 


[/expand]

  <p>&nbsp;</p>

_**Question**: Which results do you use to draw conclusion on?_


[expand title="Answer" trigclass="noarrow my_button" targclass="my_content" tag="button"]


_This really depends on where the priors come from. If for example your informative priors come from a reliable source, you should use them. The most important thing is that you choose your priors accurately, and have good arguments to use them. If not, you shouldn&#39;t use really informative priors and use the results based on the non-informative priors._


[/expand]

  <p>&nbsp;</p>
  
### 9.   Are the results stable from a sensitivity analysis?
If you still have time left, you can adjust the hyperparameters of the priors upward and downward and re-estimating the model with these varied priors to check for robustness.

From the original paper:

> "If informative or weakly-informative priors are used, then we suggest running a sensitivity analysis of these priors. When subjective priors are in place, then there might be a discrepancy between results using different subjective prior settings. A sensitivity analysis for priors would entail adjusting the entire prior distribution (i.e., using a completely different prior distribution than before) or adjusting hyperparameters upward and downward and re-estimating the model with these varied priors. Several different hyperparameter specifications can be made in a sensitivity analysis, and results obtained will point toward the impact of small fluctuations in hyperparameter values. [.] The purpose of this sensitivity analysis is to assess how much of an impact the location of the mean hyperparameter for the prior has on the posterior. [.] Upon receiving results from the sensitivity analysis, assess the impact that fluctuations in the hyperparameter values have on the substantive conclusions. Results may be stable across the sensitivity analysis, or they may be highly instable based on substantive conclusions. Whatever the finding, this information is important to report in the results and discussion sections of a paper. We should also reiterate here that original priors should not be modified, despite the results obtained."


For more information on this topic, please also refer to this [paper](http://psycnet.apa.org/record/2017-52406-001). 

### 10.   Is the Bayesian way of interpreting and reporting model results used?

For a summary on how to interpret and report models, please refer to https://www.rensvandeschoot.com/bayesian-analyses-where-to-start-and-what-to-report/


```r
summary(model)
```

```
##  Family: gaussian 
##   Links: mu = identity; sigma = identity 
## Formula: diff ~ 0 + intercept + age + age2 
##    Data: dataPHD (Number of observations: 333) 
## Samples: 4 chains, each with iter = 4000; warmup = 2000; thin = 1;
##          total post-warmup samples = 8000
## 
## Population-Level Effects: 
##           Estimate Est.Error l-95% CI u-95% CI Eff.Sample Rhat
## intercept   -36.40      4.26   -44.66   -28.06       2409 1.00
## age           2.15      0.21     1.74     2.56       2288 1.00
## age2         -0.02      0.00    -0.03    -0.02       2662 1.00
## 
## Family Specific Parameters: 
##       Estimate Est.Error l-95% CI u-95% CI Eff.Sample Rhat
## sigma    14.04      0.55    13.01    15.15       3093 1.00
## 
## Samples were drawn using sampling(NUTS). For each parameter, Eff.Sample 
## is a crude measure of effective sample size, and Rhat is the potential 
## scale reduction factor on split chains (at convergence, Rhat = 1).
```

In the current model we see that:

*  The estimate for the intercept is  -36.4 [-44.66 ;  15.15 ]
*  The estimate for the effect of $age$  is  2.15 [1.74 ; 2.56 ]
*  The estimate for the effect of $age^2$  is -0.02 [-0.03 ; -0.02 ]


We can see that none of 95% Posterior HPD Intervals for these effects include zero, which means we are can be quite certain that all of the effects are different from 0.

Remember how we plotted the relation between delay and years based on the prior information? Now, do the same with the posterior estimates.


[expand title="Answer" trigclass="noarrow my_button" targclass="my_content" tag="button"]


```r
years <- 20:80
delay <- -35 + 2.13*years - 0.02*years^2
plot(years, delay, type= "l")
```

![](Wambs-R-using-brms_files/figure-html/unnamed-chunk-33-1.png)<!-- -->

[/expand] 


  <p>&nbsp;</p>
  
---

**References**


Depaoli, S., &amp; Van de Schoot, R. (2017). Improving transparency and replication in Bayesian statistics: The WAMBS-Checklist. _Psychological Methods_, _22_(2), 240.

Link, W. A., & Eaton, M. J. (2012). On thinning of chains in MCMC. _Methods in ecology and evolution_, _3_(1), 112-115.

van Erp, S., Mulder, J., & Oberski, D. L. (2017). Prior sensitivity analysis in default Bayesian structural equation modeling.

Van de Schoot, R., &amp; Depaoli, S. (2014). Bayesian analyses: Where to start and what to report. _European Health Psychologist_, _16_(2), 75-84.


