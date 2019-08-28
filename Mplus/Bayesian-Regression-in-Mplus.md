---
title: "Regression in Mplus (Bayesian)"
author: "By [Laurent Smeets](https://www.rensvandeschoot.com/colleagues/laurent-smeets/) and [Rens van de Schoot](https://www.rensvandeschoot.com/about-rens/)"
date: 'Last modified: 26 August 2019'
output:
  html_document:
    keep_md: true
---

This tutorial provides the reader with a basic tutorial how to perform a **Bayesian regression** in [Mplus](https://www.statmodel.com/). Throughout this tutorial, the reader will be guided through importing data files, exploring summary statistics and regression analyses. Here, we will exclusively focus on [Bayesian](https://www.rensvandeschoot.com/a-gentle-introduction-to-bayesian-analysis-applications-to-developmental-research/) statistics. 

In this tutorial, we start by using the default prior settings of the software.  In a second step, we will apply user-specified priors, and if you really want to use Bayes for your own data, we recommend to follow the [WAMBS-checklist](https://www.rensvandeschoot.com/wambs-checklist/), also available in other software.

## Preparation

This tutorial expects:


- Version 8 or higher of [Mplus](https://sourceforge.net/projects/mcmc-jags/files/latest/download?source=files).This tutorial was made using Mplus version 8_3.
- Basic knowledge of hypothesis testing
- Basic knowledge of correlation and regression
- Basic knowledge of [Bayesian](https://www.rensvandeschoot.com/a-gentle-introduction-to-bayesian-analysis-applications-to-developmental-research/) inference
- Basic knowledge of coding in Mplus


## Example Data

The data we will be using for this exercise is based on a study about predicting PhD-delays ([Van de Schoot, Yerkes, Mouw and Sonneveld 2013](http://journals.plos.org/plosone/article?id=10.1371/journal.pone.0068839)).The data can be downloaded [here](https://www.rensvandeschoot.com/wp-content/uploads/2018/10/phd-delays_nonames.csv). Among many other questions, the researchers asked the Ph.D. recipients how long it took them to finish their Ph.D. thesis (n=333). It appeared that Ph.D. recipients took an average of 59.8 months (five years and four months) to complete their Ph.D. trajectory. The variable B3_difference_extra measures the difference between planned and actual project time in months (mean=9.97, minimum=-31, maximum=91, sd=14.43). For more information on the sample, instruments, methodology and research context we refer the interested reader to the paper.

For the current exercise we are interested in the question whether age (M = 31.7, SD = 6.86) of the Ph.D. recipients is related to a delay in their project.

The relation between completion time and age is expected to be non-linear. This might be due to that at a certain point in your life (i.e., mid thirties), family life takes up more of your time than when you are in your twenties or when you are older.

So, in our model the $gap$ (*B3_difference_extra*) is the dependent variable and $age$ (*E22_Age*) and $age^2$(*E22_Age_Squared *) are the predictors. The data can be found in the file <span style="color:red"> ` phd-delays_nonames.csv` </span>. (In Mplus the first row CANNOT have the variable names, these have already been deleted for you)
  <p>&nbsp;</p>


##### _**Question:** Write down the null and alternative hypotheses that represent this question. Which hypothesis do you deem more likely?_

[expand title="Answer" trigclass="noarrow my_button" targclass="my_content" tag="button"]

$H_0:$ _$age$ is not related to a delay in the PhD projects._

$H_1:$ _$age$ is related to a delay in the PhD projects._ 

$H_0:$ _$age^2$ is not related to a delay in the PhD projects._

$H_1:$ _$age^2$is related to a delay in the PhD projects._ 

[/expand]


  <p>&nbsp;</p>

## Preparation - Importing and Exploring Data



You can find the data in the file <span style="color:red"> ` phd-delays_nonames.csv` </span>, which contains all variables that you need for this analysis. Although it is a .csv-file, you can directly load it into Mplus using the following syntax:


```r
TITLE: Bayesian analysis summary
DATA: FILE IS phd-delays_nonames.csv;
VARIABLE: NAMES ARE diff child sex Age Age2;
USEVARIABLES ARE diff Age Age2;
OUTPUT: sampstat;
```

Once you loaded in your data, it is advisable to check whether your data import worked well. Therefore, first have a look at the summary statistics of your data. You can do this by looking at the `sampstat` ouput. 

<p>&nbsp;</p>

##### _**Question:** Have all your data been loaded in correctly? That is, do all data points substantively make sense? If you are unsure, go back to the .csv-file to inspect the raw data._

[expand title="Answer" trigclass="noarrow my_button" targclass="my_content" tag="button"]


```r
MODEL RESULTS

                                                    Two-Tailed
                    Estimate       S.E.  Est./S.E.    P-Value

 Means
    DIFF               9.967      0.790     12.622      0.000
    AGE               31.676      0.375     84.433      0.000
    AGE2            1050.217     35.916     29.241      0.000
```


_The descriptive statistics make sense:_

_$diff$: Mean (9.97), SE (0.79)_

_$Age$: Mean (31.68), SE (0.38)_

_$Age^2$: Mean (1050.22), SE (35.92)_

[/expand]

  <p>&nbsp;</p>

## Regression - Default Priors

In this exercise you will investigate the impact of Ph.D. students&#39; $age$ and $age^2$ on the delay in their project time, which serves as the outcome variable using a regression analysis (note that we ignore assumption checking!).



As you know, Bayesian inference consists of combining a prior distribution with the likelihood obtained from the data. Specifying a prior distribution is one of the most crucial points in Bayesian inference and should be treated with your highest attention (for a quick refresher see e.g.  [Van de Schoot et al. 2017](http://onlinelibrary.wiley.com/doi/10.1111/cdev.12169/abstract)). In this tutorial, we will first rely on the default prior settings, thereby behaving a &#39;naive&#39; Bayesians (which might [not](https://www.rensvandeschoot.com/analyzing-small-data-sets-using-bayesian-estimation-the-case-of-posttraumatic-stress-symptoms-following-mechanical-ventilation-in-burn-survivors/) always be a good idea).

To run a multiple regression with Mplus, you first specify the model (after the `MODEL line` using the `ON command` for regression coefficients, and the `[]` command for the intercept). As default Mplus does not run a Bayesian analysis, so you would have to change the `ESTIMATOR` to `BAYES` under `ANALYSIS` in the input file and then look at the output under `MODEL RESULTS`.



```r
TITLE: Bayesian analysis with default priors

DATA: FILE IS phd-delays_nonames.csv;

VARIABLE: NAMES ARE diff child sex Age Age2; ! All the variables in the dataset

USEVARIABLES ARE diff Age Age2; ! The variables we use in this analysis

ANALYSIS:
ESTIMATOR IS bayes; ! Specify that we want to use a Bayesian analysis
Bseed = 23082018; !specify a seed value for reproducing the results
CHAINS = 3; ! set the number of chains we want to use

MODEL: 
[diff] (intercept);       ! specify that we want an intercept
! this model would also work without this line, but this way it is possible to easily set a prior
diff ON Age (Beta_Age);   ! Regression coefficient 1. 
diff ON Age2(Beta_Age2);  ! Regression coefficient 2 
! You need to name these regression coefficients to later set priors
diff (e);                 ! Error variance


OUTPUT: tech8; ! Specify the output we would like
```


[expand title="The Mplus table `MODEL RESULTS" trigclass="noarrow my_button" targclass="my_content" tag="button"]



```r
MODEL RESULTS

                                Posterior  One-Tailed         95% C.I.
                    Estimate       S.D.      P-Value   Lower 2.5%  Upper 2.5%  Significance

 DIFF       ON
    AGE                2.647       0.622      0.000       1.348       3.874      *
    AGE2              -0.026       0.007      0.000      -0.039      -0.013      *

 Intercepts
    DIFF             -46.578      12.898      0.000     -70.394     -21.095      *

 Residual Variances
    DIFF             198.117      16.978      0.000     171.316     232.769      *
```
[/expand]

 
  The results that stem from a Bayesian analysis are genuinely different from those that are provided by a frequentist model. 

[expand title=Read more on the Bayesian analysis]

The key difference between Bayesian statistical inference and frequentist statistical methods concerns the nature of the unknown parameters that you are trying to estimate. In the frequentist framework, a parameter of interest is assumed to be unknown, but fixed. That is, it is assumed that in the population there is only one true population parameter, for example, one true mean or one true regression coefficient. In the Bayesian view of subjective probability, all unknown parameters are treated as uncertain and therefore are be described by a probability distribution. Every parameter is unknown, and everything unknown receives a distribution.


This is why in frequentist inference, you are primarily provided with a point estimate of the unknown but fixed population parameter. This is the parameter value that, given the data, is most likely in the population. An accompanying confidence interval tries to give you further insight in the uncertainty that is attached to this estimate. It is important to realize that a confidence interval simply constitutes a simulation quantity. Over an infinite number of samples taken from the population, the procedure to construct a (95%) confidence interval will let it contain the true population value 95% of the time. This does not provide you with any information how probable it is that the population parameter lies within the confidence interval boundaries that you observe in your very specific and sole sample that you are analyzing. 

In Bayesian analyses, the key to your inference is the parameter of interest&#39;s posterior distribution. It fulfills every property of a probability distribution and quantifies how probable it is for the population parameter to lie in certain regions. On the one hand, you can characterize the posterior by its mode. This is the parameter value that, given the data and its prior probability, is most probable in the population. Alternatively, you can use the posterior&#39;s mean or median. Using the same distribution, you can construct a 95% credibility interval, the counterpart to the confidence interval in frequentist statistics. Other than the confidence interval, the Bayesian counterpart directly quantifies the probability that the population value lies within certain limits. There is a 95% probability that the parameter value of interest lies within the boundaries of the 95% credibility interval. Unlike the confidence interval, this is not merely a simulation quantity, but a concise and intuitive probability statement. For more on how to interpret Bayesian analysis, check [Van de Schoot et al. 2014](http://onlinelibrary.wiley.com/doi/10.1111/cdev.12169/abstract).

[/expand]

##### _**Question:** Interpret the estimated effect, its interval and the posterior distribution._

[expand title="Answer" trigclass="noarrow my_button" targclass="my_content" tag="button"]


_$Age$ seems to be a relevant predictor of PhD delays, with a posterior mean regression coefficient of  2.647, 95% Credibility Interval [1.35,  3.87]. Also, $age^2$ seems to be a relevant predictor of PhD delays, with a posterior mean of -0.026, and a 95% Credibility Interval of [-0.04, -0.01]. The 95% Credibility Interval shows that there is a 95% probability that these regression coefficients in the population lie within the corresponding intervals, see also the posterior distributions in the figures below. Since 0 is not contained in the Credibility Interval we can be fairly sure there is an effect._


[/expand]

  <p>&nbsp;</p> 

##### _**Question:** Every Bayesian model uses a prior distribution. Describe the shape of the prior distribution._

[expand title="Answer" trigclass="noarrow my_button" targclass="my_content" tag="button"]

_To see what default priors Mplus uses we can have a look at the Appendix A of this [manual](https://www.statmodel.com/download/BayesAdvantages18.pdf). "The default prior for intercepts, regression slopes, and loading parameters is $\beta \sim \mathcal{N}(0, \infty)$." This means in practice that we have a normal prior with a super wide variance,  and allow probability mass across the entire parameter space. The default priors can also be found in the TECH8 output of Mplus_


```r
     PRIORS FOR ALL PARAMETERS            PRIOR MEAN      PRIOR VARIANCE     PRIOR STD. DEV.

     Parameter 1~N(0.000,infinity)           0.0000            infinity            infinity
     Parameter 2~N(0.000,infinity)           0.0000            infinity            infinity
     Parameter 3~N(0.000,infinity)           0.0000            infinity            infinity
     Parameter 4~IG(-1.000,0.000)          infinity            infinity            infinity
```


[/expand]


## Regression - User-specified Priors
In Mplus, you can also manually specify your prior distributions. Be aware that usually, this has to be done BEFORE peeking at the data, otherwise you are double-dipping (!). In theory, you can specify your prior knowledge using any kind of distribution you like. However, if your prior distribution does not follow the same parametric form as your likelihood, calculating the model can be computationally intense. _Conjugate_ priors avoid this issue, as they take on a functional form that is suitable for the model that you are constructing. For your normal linear regression model, conjugacy is reached if the priors for your regression parameters are specified using normal distributions (the residual variance receives an inverse gamma distribution, which is neglected here). In Mplus, you are quite flexible in the specification of informative priors.

Let&#39;s re-specify the regression model of the exercise above, using conjugate priors. We leave the priors for the intercept and the residual variance untouched for the moment. Regarding your regression parameters, you need to specify the hyperparameters of their normal distribution, which are the mean and the variance. The mean indicates which parameter value you deem most likely. The variance expresses how certain you are about that. We try 4 different prior specifications (for now we only look at the priors for the regression coefficients and ignore the intercept and the error term), for both the $\beta_{age}$ regression coefficient, and the $\beta_{age^2}$ coefficient.

First, we use the following prior specifications:

_$Age$ ~ N(3, 0.4)_

_$Age^2$ N(0, 0.1)_

In Mplus, the priors are set in the under the `MODEL PRIORS` command using the `~` sign and an `N` for a normal distribution

The priors are presented in code as follows:



```r
MODEL: 
[diff] (intercept);       ! specify that we want an intercept
diff ON Age (Beta_Age);   ! Regression coefficient 1
diff ON Age2(Beta_Age2);  ! Regression coefficient 2 
diff (e);                 ! Error variance


MODEL PRIORS:
  Beta_Age ~ N(3, .4);
  Beta_Age2 ~ N(0, .1);
```


  <p>&nbsp;</p>
 
#### _**Question** Fill in the results in the table below:_



| Age            | Default prior | N(3, 0.4) | N(3, 1000) | N(20, 0.4) | N(20, 1000) |
| ---            | ---           | ---       | ---        |---         | ---         |
| Posterior mean |  2.64         |           |            |            |             | 
| Posterior sd   |  0.62         |           |            |            |             |

| Age squared    | Default prior | N(0, 0.1) | N(0, 1000) | N(20, 0.1) | N(20, 1000) |
| ---            | ---           | ---       | ---        | ---        | ---         |
| Posterior mean | -0.026        |           |            |            |             |
| Posterior sd   | 0.007         |           |            |            |             |



[expand title="Answer" trigclass="noarrow my_button" targclass="my_content" tag="button"]

The results can again be found in the `MODEL RESULTS` table



```r
MODEL RESULTS

                                Posterior  One-Tailed         95% C.I.
                    Estimate       S.D.      P-Value   Lower 2.5%  Upper 2.5%  Significance

 DIFF       ON
    AGE                2.794       0.460      0.000       1.863       3.697      *
    AGE2              -0.027       0.005      0.000      -0.038      -0.017      *

 Intercepts
    DIFF             -50.109       9.537      0.000     -67.545     -30.948      *

 Residual Variances
    DIFF             198.178      16.947      0.000     171.160     232.840      *
```





| Age            | Default prior | N(3, 0.4) | N(3, 1000) | N(20, 0.4) | N(20, 1000) |
| ---            | ---           | ---       | ---        |---         | ---         |
| Posterior mean |  2.64         |2.79       |            |            |             | 
| Posterior sd   |  0.62         |0.46       |            |            |             |

| Age squared    | Default prior | N(0, 0.1) | N(0, 1000) | N(20, 0.1) | N(20, 1000) |
| ---            | ---           | ---       | ---        | ---        | ---         |
| Posterior mean | -0.026        |-0.027     |            |            |             |
| Posterior sd   | 0.007         |0.005      |            |            |             |


[/expand]

Next, try to adapt the code, using the prior specifications of the other columns. Make the table complete after the different prior specifications were used.


[expand title="Answer" trigclass="noarrow my_button" targclass="my_content" tag="button"]

You can change these lines of code in the Mplus input:


```r
MODEL PRIORS:
  Beta_Age ~ N(3, 0.4);
  Beta_Age2 ~ N(0, 0.1);
```


```r
MODEL PRIORS:
  Beta_Age ~ N(3, 1000);
  Beta_Age2 ~ N(0, 1000);
```


```r
MODEL PRIORS:
  Beta_Age ~ N(20, 0.4);
  Beta_Age2 ~ N(20, 0.1);
```


| Age            | Default prior | N(3, 0.4) | N(3, 1000) | N(20, 0.4) | N(20, 1000) |
| ---            | ---           | ---       | ---        |---         | ---         |
| Posterior mean |  2.64         |2.79       |   2.64     |  13.78     |   2.654     | 
| Posterior sd   |  0.62         |0.46       |   0.62     |     0.73   |   0.62      |

| Age squared    | Default prior | N(0, 0.1) | N(0, 1000) | N(20, 0.1) | N(20, 1000) |
| ---            | ---           | ---       | ---        | ---        | ---         |
| Posterior mean | -0.026        |-0.027     |  -0.026    |  -0.14     |  -0.026     |
| Posterior sd   | 0.007         |0.005      |    0.007   |     0.008  |     0.007   |

[/expand]


  <p>&nbsp;</p>
 
#### _**Question**: Compare the results over the different prior specifications. Are the results comparable with the default model?_

#### _**Question**: Do we end up with similar conclusions, using different prior specifications?_

_To answer these questions, proceed as follows: We can calculate the relative bias to express this difference. ($bias= 100*\frac{(model \; informative\; priors\;-\;model \; uninformative\; priors)}{model \;uninformative \;priors}$). In order to preserve clarity we will just calculate the bias of the two regression coefficients and only compare the default (uninformative) model to the model that uses the $\mathcal{N}(20, .4)$ and $\mathcal{N}(20, .1)$ priors_


[expand title="Answer" trigclass="noarrow my_button" targclass="my_content" tag="button"]


($100*\frac{(13.78 - 2.64 )}{2.64}=428\%$)

($100*\frac{(-0.014--0.026  )}{-0.026}=-46.15\%$)

_We see that the influence of this highly informative prior is around 428% and 46.15% on the two regression coefficients respectively._

_The results change with different prior specifications, but are still comparable. Only using $\mathcal{N}(20, .4)$ for age, results in a really different coefficients, since this prior mean is far from the mean of the data, while its variance is quite certain. However, in general the other results are comparable. Because we use a big dataset the influence of the prior is relatively small. If one would use a smaller dataset the influence of the priors are larger._ 


[/expand]


  <p>&nbsp;</p>
 

 

If you really want to use Bayes for your own data, we recommend to follow the [WAMBS-checklist](https://www.rensvandeschoot.com/wambs-checklist/), which you are guided through by this exercise.


--- 
### **References**

_Benjamin, D. J., Berger, J., Johannesson, M., Nosek, B. A., Wagenmakers, E.,... Johnson, V. (2017, July 22)._ [Redefine statistical significance](https://psyarxiv.com/mky9j)_. Retrieved from psyarxiv.com/mky9j_

_Greenland, S., Senn, S. J., Rothman, K. J., Carlin, J. B., Poole, C., Goodman, S. N. Altman, D. G. (2016)._ [Statistical tests, P values, confidence intervals, and power: a guide to misinterpretations](https://link.springer.com/article/10.1007/s10654-016-0149-3)_._ _European Journal of Epidemiology 31 (4_). [_https://doi.org/10.1007/s10654-016-0149-3_](https://doi.org/10.1007/s10654-016-0149-3) 

_Hoffman, M. D., & Gelman, A. (2014)_. The No-U-turn sampler: adaptively setting path lengths in Hamiltonian Monte Carlo. Journal of Machine Learning Research, 15(1), 1593-1623.

_van de Schoot R, Yerkes MA, Mouw JM, Sonneveld H (2013)_ [What Took Them So Long? Explaining PhD Delays among Doctoral Candidates](http://journals.plos.org/plosone/article?id=10.1371/journal.pone.0068839)_._ _PLoS ONE 8(7): e68839._ [https://doi.org/10.1371/journal.pone.0068839](https://doi.org/10.1371/journal.pone.0068839)

_Trafimow D, Amrhein V, Areshenkoff CN, Barrera-Causil C, Beh EJ, Bilgi? Y, Bono R, Bradley MT, Briggs WM, Cepeda-Freyre HA, Chaigneau SE, Ciocca DR, Carlos Correa J, Cousineau D, de Boer MR, Dhar SS, Dolgov I, G?mez-Benito J, Grendar M, Grice J, Guerrero-Gimenez ME, Guti?rrez A, Huedo-Medina TB, Jaffe K, Janyan A, Karimnezhad A, Korner-Nievergelt F, Kosugi K, Lachmair M, Ledesma R, Limongi R, Liuzza MT, Lombardo R, Marks M, Meinlschmidt G, Nalborczyk L, Nguyen HT, Ospina R, Perezgonzalez JD, Pfister R, Rahona JJ, Rodr?guez-Medina DA, Rom?o X, Ruiz-Fern?ndez S, Suarez I, Tegethoff M, Tejo M, ** van de Schoot R** , Vankov I, Velasco-Forero S, Wang T, Yamada Y, Zoppino FC, Marmolejo-Ramos F. (2017)_  [Manipulating the alpha level cannot cure significance testing - comments on &quot;Redefine statistical significance&quot;](https://www.rensvandeschoot.com/manipulating-alpha-level-cannot-cure-significance-testing/) PeerJ reprints 5:e3411v1   [https://doi.org/10.7287/peerj.preprints.3411v1](https://doi.org/10.7287/peerj.preprints.3411v1)

