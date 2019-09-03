* Encoding: UTF-8.
***********************************************************************
* T-test in SPSS
* Lion Behrens, Naomi Schalken and Rens van de Schoot 
* Syntax file
***********************************************************************

* Loading in data (fill in your working directory).
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
EXAMINE VARIABLES=B3_difference_extra E4_having_child
  /PLOT BOXPLOT STEMLEAF
  /COMPARE GROUPS
  /STATISTICS DESCRIPTIVES
  /CINTERVAL 95
  /MISSING LISTWISE
  /NOTOTAL.

* T-test. 
T-TEST GROUPS=E4_having_child (0 1)
    /MISSING=ANALYSIS
    /VARIABLES=B3_difference_extra 
    /CRITERIA=CI(.95).
