* Encoding: UTF-8.
***********************************************************************
* Regression in SPSS
* Lion Behrens, Naomi Schalken and Rens van de Schoot 
* Syntax file
***********************************************************************

* Loading in data (fill in your own working directory).
GET DATA  /TYPE=TXT 
  /FILE="C:\your working directory\phd-delays.csv"    
  /DELCASE=LINE 
  /DELIMITERS=";" 
  /ARRANGEMENT=DELIMITED 
  /FIRSTCASE=2 
  /DATATYPEMIN PERCENTAGE=95.0 
  /VARIABLES= 
  B3_difference_extra AUTO 
  E4_having_child AUTO 
  E21_sex AUTO 
  E22_Age AUTO 
  E22_Age_Squared AUTO 
  /MAP. 
RESTORE. 
CACHE. 
EXECUTE.

* Descriptive Statistics. 
EXAMINE VARIABLES=B3_difference_extra E22_Age E22_Age_Squared
  /PLOT BOXPLOT STEMLEAF
  /COMPARE GROUPS
  /STATISTICS DESCRIPTIVES
  /CINTERVAL 95
  /MISSING LISTWISE
  /NOTOTAL.

* Multiple linear regression. 
REGRESSION
  /MISSING PAIRWISE
  /STATISTICS COEFF OUTS CI(95) R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN
  /DEPENDENT B3_difference_extra
  /METHOD=ENTER E22_Age E22_Age_Squared.


