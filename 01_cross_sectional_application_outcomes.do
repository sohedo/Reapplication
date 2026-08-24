/*===============================================================================
  Persistence in reapplying to university after rejection
  File:    01_cross_sectional_application_outcomes.do
  Purpose: Cross-sectional analysis of university application outcomes

  Load the prepared person-level data before running this file.

  These analyses are separate from the longitudinal discrete-time analysis.

  applicationoutcomes:
      1 = Never applied
      2 = Rejected
      3 = Direct admission

  The rejected category combines individuals who applied without success and
  individuals who were rejected and later successfully reapplied.

===============================================================================*/


* -----------------------------------------------------------------------------
* Table 1: descriptive comparisons of application outcomes
* -----------------------------------------------------------------------------

tab applicationoutcomes

foreach var in use_uni_parents use_earnings_3 female ///
    mental17until ever_psychotropic_a {

    tab `var' applicationoutcomes, col chi2
}

* Parental EA-PGS: mean, SD, and group comparison
tabstat use_Educational_attainment_PRS, ///
    by(applicationoutcomes) stats(mean sd n)

anova use_Educational_attainment_PRS applicationoutcomes


* -----------------------------------------------------------------------------
* Cross-sectional multivariable analysis of application outcomes
* -----------------------------------------------------------------------------
* Multinomial logistic regression:
*   outcome 1 vs 2 = Never applied vs Rejected
*   outcome 3 vs 2 = Direct admission vs Rejected
*
* Rejected applicants (outcome 2) are the reference category.

mlogit applicationoutcomes ///
    i.use_uni_parents ///
    b2.use_earnings_3 ///
    i.female ///
    i.mental17until ///
    c.use_Educational_attainment_PRS ///
    i.yearofbirth ///
    i.nuts2 ///
    use_PC1-use_PC10 ///
    i.use_sample ///
    i.sfm_PRS, ///
    b(2) robust

est sto modelnew
