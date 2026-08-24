/*===============================================================================
  Persistence in reapplying to university after rejection
  File:    03_discrete_time_models.do
  Purpose: Estimate the logistic discrete-time hazard models of stop applying
           after rejection reported in Table 2 and Figures 2-3.

  Load the prepared data and required add-ons before running this file.
===============================================================================*/

Stata version 18


* -----------------------------------------------------------------------------
* Interaction terms used in the GxE model
* -----------------------------------------------------------------------------
* These are the manually coded product terms used in the original analysis.
* The middle parental-income group is the reference category, so only the
* low- and high-income product terms enter the GxE model.

tab use_earnings_3, gen(faminc)
gen pedu_PRS   = use_uni_parents * use_Educational_attainment_PRS
gen faminc1_PRS = faminc1 * use_Educational_attainment_PRS
gen faminc2_PRS = faminc2 * use_Educational_attainment_PRS
gen faminc3_PRS = faminc3 * use_Educational_attainment_PRS

* sfm_PRS identifies whether the parental EA-PGS comes from the mother or father.
* Parental SES variables refer to the non-genotyped parent.

* -----------------------------------------------------------------------------
* Proportionality check used in the original analysis
* -----------------------------------------------------------------------------
* hakukerta is the non-parametric baseline hazard. The relaxed specification
* allows the association with parental EA-PGS to vary over follow-up time.

logit event c.use_Educational_attainment_PRS ib2.hakukerta use_PC1-use_PC10, or
est sto basic

logit event c.use_Educational_attainment_PRS##b2.hakukerta use_PC1-use_PC10, or
est sto relaxed

lrtest basic relaxed

* The relaxed specification did not improve model fit in the original analysis.

* -----------------------------------------------------------------------------
* Table 2
* -----------------------------------------------------------------------------
* After each logit model, margins, dydx(*) post calculates the average marginal
* effects reported in the table and stores them as the current estimates.
*
* The estimate names model2-model5 are retained from the original analysis.
* They correspond to Models 1-4 in Table 2.

* Model 1: family background and life circumstances
logit event i.use_uni_parents ib2.use_earnings_3 ib2.hakukerta ///
    i.lapsi c.tulo_p i.poly i.syntyv i.female i.tyke_3kk ///
    i.vuosi_yoL use_PC1-use_PC10 i.nuts2 i.use_sample i.sfm_PRS
margins, dydx(*) post
est sto model2

* Model 2: + mental health indicators
logit event i.use_uni_parents ib2.use_earnings_3 ib2.hakukerta ///
    i.lapsi c.tulo_p i.poly i.syntyv i.female i.tyke_3kk ///
    i.mental17until i.psychotropic_a i.vuosi_yoL ///
    use_PC1-use_PC10 i.nuts2 i.use_sample i.sfm_PRS
margins, dydx(*) post
est sto model3

* Model 3: + parental EA-PGS
logit event c.use_Educational_attainment_PRS i.use_uni_parents ///
    ib2.use_earnings_3 ib2.hakukerta i.lapsi c.tulo_p i.poly ///
    i.syntyv i.female i.tyke_3kk i.mental17until ///
    i.psychotropic_a i.vuosi_yoL use_PC1-use_PC10 ///
    i.nuts2 i.use_sample i.sfm_PRS
margins, dydx(*) post
est sto model4

* Model 4: + GxE interactions
logit event c.use_Educational_attainment_PRS i.use_uni_parents ///
    ib2.use_earnings_3 pedu_PRS faminc1_PRS faminc3_PRS ///
    ib2.hakukerta i.lapsi c.tulo_p i.poly i.syntyv i.female ///
    i.tyke_3kk i.mental17until i.vuosi_yoL use_PC1-use_PC10 ///
    i.nuts2 i.use_sample i.psychotropic_a i.sfm_PRS
margins, dydx(*) post
est sto model5

* Display the four models reported in Table 2.
esttab model2 model3 model4 model5, b(3) se(3) stats(N r2)

* -----------------------------------------------------------------------------
* Figure 2: parental EA-PGS x parental education
* -----------------------------------------------------------------------------
logit event i.use_EducationPGS_5##i.use_uni_parents i.use_earnings_3 ///
    pedu_PRS faminc1_PRS faminc3_PRS ib2.hakukerta i.lapsi c.tulo_p ///
    i.poly i.syntyv i.female i.tyke_3kk use_PC1-use_PC10 i.nuts2 ///
    i.use_sample i.mental17until i.psychotropic_a i.sfm_PRS

margins use_EducationPGS_5, over(use_uni_parents)
marginsplot, ytitle("Predicted probabilities") ///
    title("Stop applying to university") ///
    xtitle("PGS Educational attainment") scheme(s1mono)

* -----------------------------------------------------------------------------
* Figure 3: parental EA-PGS x parental income
* -----------------------------------------------------------------------------
logit event i.use_EducationPGS_5##i.use_earnings_3 i.use_uni_parents ///
    pedu_PRS faminc1_PRS faminc3_PRS ib2.hakukerta i.lapsi c.tulo_p ///
    i.poly i.syntyv i.female i.tyke_3kk use_PC1-use_PC10 i.nuts2 ///
    i.use_sample i.mental17until i.psychotropic_a i.sfm_PRS

margins use_EducationPGS_5, over(use_earnings_3)
marginsplot, ytitle("Predicted probabilities") ///
    title("Stop applying to university") ///
    xtitle("PGS Educational attainment") scheme(s1mono)
