---
title: 'Influence of Priors: Popularity Data'
author: "By [Laurent Smeets](https://www.rensvandeschoot.com/colleagues/laurent-smeets/) and [Rens van de Schoot](https://www.rensvandeschoot.com/about-rens/)"
date: 'Last modified: 08 August 2019'
output:
  html_document:
    keep_md: true
---


## Introduction

**This is part 2 of a 3 part  [series](https://www.rensvandeschoot.com/tutorials/brms/) on how to do multilevel models in the Bayesian framework. In [part 1](https://www.rensvandeschoot.com/tutorials/brms-started/) we explained how to step by step build the multilevel model we will use here and in  [part 3](https://www.rensvandeschoot.com/brms-wambs/) we will look at the influence of different priors  ** 


## Preparation
This tutorial expects:

-  Basic knowledge of multilevel analyses (first two chapters of the book are sufficient).
-  Basic knowledge of coding in R, specifically the [LME4 package](https://www.rensvandeschoot.com/tutorials/lme4/).
-  Basic knowledge of Bayesian Statistics.
- Installation of [STAN](https://mc-stan.org/users/interfaces/rstan) and [Rtools](https://cran.r-project.org/bin/windows/Rtools). For more information please see https://github.com/stan-dev/rstan/wiki/RStan-Getting-Started
- Installation of R packages `rstan`, and `brms`. This tutorial was made using brms version 2.8.0 in R version 3.6.0
- Basic knowledge of [Bayesian](https://www.rensvandeschoot.com/a-gentle-introduction-to-bayesian-analysis-applications-to-developmental-research/) inference


## priors
As stated in the BRMS manual: *"Prior specifications are flexible and explicitly encourage users to apply prior distributions that actually reflect their beliefs."* 

We will set 4 types of extra priors here (in a addition to the uninformative prior we have used thus far)
1.  With an estimate far off the value we found in the data with uninformative priors with a wide variance
2.  With an estimate close to the value we found in the data with uninformative priors with a small variance
3.  With an estimate far off the value we found in the data with uninformative priors with a small variance (1).
4.  With an estimate far off the value we found in the data with uninformative priors with a small variance (2).

In this tutorial we will only focus on priors for the regression coefficients and not on the error and variance terms, since we are most likely to actually have information on the size and direction of a certain effect and less (but not completely) unlikely to have prior knowledge on the unexplained variances. You might have to play around a little bit with the controls of the brm function and specifically the adapt_delta and  max_treedepth. Thankfully BRMS will tell you when to do so. We can also did not set highly informative priors for all regression coefficients at once, because this leads to the blowing up of estimates convergence issues (potentially solvebale by just running many more iterations)


## STEP 1: setting up packages
n order to make the [brms package](https://cran.r-project.org/web/packages/brms/index.html) function it need to call on STAN and a C++ compiler. For more information and a tutorial on how to install these please have a look at: https://github.com/stan-dev/rstan/wiki/RStan-Getting-Started and https://cran.r-project.org/bin/windows/Rtools/.

> "Because brms is based on Stan, a C++ compiler is required. The program Rtools (available on https://cran.r-project.org/bin/windows/Rtools/) comes with a C++ compiler for Windows. On Mac, you should use Xcode. For further instructions on how to get the compilers running, see the prerequisites section at the RStan-Getting-Started page." ~ quoted from the  BRMS package document

After you have install the aforementioned software you need to load some other R packages. If you have not yet installed all below mentioned packages, you can install them by the command install.packages("NAMEOFPACKAGE")


```r
library(brms) # for the analysis
library(haven) # to load the SPSS .sav file
library(tidyverse) # needed for data manipulation.
library(RColorBrewer) # needed for some extra colours in one of the graphs
library(ggmcmc)
library(ggthemes)
library(lme4)
```


&nbsp;
# Step 2: Downloading the data

The popularity dataset contains characteristics of pupils in different classes. The main goal of this tutorial is to find models and test hypotheses about the relation between these characteristics and the popularity of pupils (according to their classmates). To download the popularity data go to https://multilevel-analysis.sites.uu.nl/datasets/ and follow the links to https://github.com/MultiLevelAnalysis/Datasets-third-edition-Multilevel-book/blob/master/chapter%202/popularity/SPSS/popular2.sav. We will use the .sav file which can be found in the SPSS folder. After downloading the data to your working directory you can open it with the read_sav() command.

Alternatively, you can directly download them from GitHub into your R work space using the following command:


```r
popular2data <- read_sav(file ="https://github.com/MultiLevelAnalysis/Datasets-third-edition-Multilevel-book/blob/master/chapter%202/popularity/SPSS/popular2.sav?raw=true")
```

There are some variables in the dataset that we do not use, so we can select the variables we will use and have a look at the first few observations.


```r
popular2data <- select(popular2data, pupil, class, extrav, sex, texp, popular) # we select just the variables we will use
head(popular2data) # we have a look at the first 6 observations
```

```
## # A tibble: 6 x 6
##   pupil class extrav       sex  texp popular
##   <dbl> <dbl>  <dbl> <dbl+lbl> <dbl>   <dbl>
## 1     1     1      5  1 [girl]    24     6.3
## 2     2     1      7  0 [boy]     24     4.9
## 3     3     1      4  1 [girl]    24     5.3
## 4     4     1      3  1 [girl]    24     4.7
## 5     5     1      5  1 [girl]    24     6  
## 6     6     1      4  0 [boy]     24     4.7
```


## The Effect of Priors
With the get_prior() command we can see which priors we can specify for this model. 


```r
get_prior(popular~1 + sex + extrav + texp + extrav:texp + (1 + extrav | class), data = popular2data)
```

```
##                  prior     class        coef group resp dpar nlpar bound
## 1                              b                                        
## 2                              b      extrav                            
## 3                              b extrav:texp                            
## 4                              b         sex                            
## 5                              b        texp                            
## 6               lkj(1)       cor                                        
## 7                            cor             class                      
## 8  student_t(3, 5, 10) Intercept                                        
## 9  student_t(3, 0, 10)        sd                                        
## 10                            sd             class                      
## 11                            sd      extrav class                      
## 12                            sd   Intercept class                      
## 13 student_t(3, 0, 10)     sigma
```

For the first model with priors we just set normal priors for all regression coefficients, in reality many, many more prior distributions are possible, see the [BRMS manual](https://cran.r-project.org/web/packages/brms/brms.pdf) for an overview.

```r
prior1 <- c(set_prior("normal(-10,100)", class = "b", coef= "extrav"),
            set_prior("normal(10,100)", class = "b", coef= "extrav:texp"),
            set_prior("normal(-5,100)", class = "b", coef= "sex"),
            set_prior("normal(-5,100)", class = "b", coef= "texp"),
            set_prior("normal(10,100)", class = "Intercept"))
```



```r
model6 <- brm(popular ~ 1 + sex + extrav + texp + extrav:texp + (1 + extrav|class), 
              data  = popular2data, warmup = 1000,
              iter  = 3000, chains = 2, 
              seed  = 123, control = list(adapt_delta = 0.97),
              cores = 2) # to reach a usuable number effective samples in the posterior distribution of the interaction effect, we need many more iteration. This sampler will take quite some time and you might want to run it with a few less iterations.
```

To see which priors were inserted, use the prior_summary() command

```r
prior_summary(model6)
```

```
##                   prior     class        coef group resp dpar nlpar bound
## 1                               b                                        
## 2                               b      extrav                            
## 3                               b extrav:texp                            
## 4                               b         sex                            
## 5                               b        texp                            
## 6   student_t(3, 5, 10) Intercept                                        
## 7  lkj_corr_cholesky(1)         L                                        
## 8                               L             class                      
## 9   student_t(3, 0, 10)        sd                                        
## 10                             sd             class                      
## 11                             sd      extrav class                      
## 12                             sd   Intercept class                      
## 13  student_t(3, 0, 10)     sigma
```

