/*===============================================================================
  Persistence in reapplying to university after rejection
  File:    01_build_discrete_time_sample.do
  Purpose: Construct the person-year sample for the logistic discrete-time
           hazard analysis of stop applying after rejection.

  Load the prepared data and required add-ons before running this file.
===============================================================================*/

Stata version 18

* Restrict observations to age 24 or younger.
gen age = vuosi - syntyv
drop if age > 24

* Annual indicators for applying and university admission.
gen hakee = 0
replace hakee = 1 if access != .
label define hakee_lab 0 "Not applying" 1 "Applying"
label values hakee hakee_lab

gen paasee = 0
replace paasee = 1 if access == 1
label define paasee_l 0 "No access" 1 "Access"
label values paasee paasee_l

* hakukerta is the annual clock from the first application onward.
* It is not the number of applications.
gen hakukerta = 0
sort child_shnro vuosi
replace hakukerta = hakukerta[_n-1] + 1 if ///
    child_shnro == child_shnro[_n-1] & ///
    (access != . | hakukerta[_n-1] > 0)

* Start follow-up in the year after the first rejected application.
* If the first application led to admission, later applications do not enter
* the post-rejection analysis.
bysort child_shnro: egen firstappyear = min(vuosi) if hakee[_n-1] == 1
bysort child_shnro: egen startyear = min(vuosi) if ///
    hakee[_n-1] == 1 & paasee[_n-1] == 0
replace startyear = . if firstappyear != startyear
gen start = 1 if vuosi == startyear
drop firstappyear
bysort child_shnro (vuosi): replace startyear = startyear[_n-1] if missing(startyear)

* End follow-up at the first of four possible endpoints.

* 1) Stop applying: first year without an application after follow-up starts.
* A gap year is therefore coded as stop applying.
bysort child_shnro: egen firsteventyear = min(vuosi) if ///
    hakee == 0 & startyear != .
gen event = 1 if vuosi == firsteventyear

* 2) Admission to university after rejection.
bysort child_shnro: egen acceptyear = min(vuosi) if ///
    paasee == 1 & startyear != .
gen accept = 1 if vuosi == acceptyear

* 3) Four years of follow-up.
bysort child_shnro (vuosi): gen countfromstart = 1 if start == 1
bysort child_shnro (vuosi): replace countfromstart = countfromstart[_n-1] + 1 if ///
    countfromstart[_n-1] != . & missing(countfromstart)
gen fourendyear = vuosi if countfromstart == 4

* 4) Last observed year.
bysort child_shnro (vuosi): gen lastyear = vuosi if ///
    _n == _N & startyear != .

* The earliest endpoint defines the end of follow-up.
gen endyear = firsteventyear
replace endyear = acceptyear if acceptyear != .
replace endyear = fourendyear if fourendyear != .
replace endyear = lastyear if lastyear != .
rename endyear endyearAll
bysort child_shnro: egen endyear = min(endyearAll)
replace endyear = . if startyear == .

* Keep person-years from entry through the endpoint and code the outcome.
gen sample = .
bysort child_shnro: replace sample = 1 if ///
    inrange(vuosi, startyear, endyear) & !missing(startyear, endyear)

keep if sample == 1

drop start startyear firsteventyear acceptyear countfromstart ///
    fourendyear lastyear endyearAll endyear sample accept

replace event = 0 if event == .
label define event_lab 0 "Continues / censored / admitted" 1 "Stops applying"
label values event event_lab

sort child_shnro hakukerta
