// =======
// Table A7: MHT
// =======

** Note: This program may take more than one hour to complete.

** set path **
local path_data "$root/Data/"
local path_results "$root/Results/"

use "`path_data'/data_main.dta", clear

*******************
**** Section 1 ****
*******************

gen treatment = after*experiment

eststo clear
reghdfe quality after##experiment, absorb(month id class teacher) vce(cluster id)
eststo table1_1
reghdfe error after##experiment, absorb(month id class teacher) vce(cluster id)
eststo table1_2
reghdfe criticalerror after##experiment, absorb(month id class teacher) vce(cluster id)
eststo table1_3
reghdfe error_magnitude after##experiment, absorb(month id class teacher) vce(cluster id)
eststo table1_4
#delimit ;
esttab table1_*  using "MHT_1.csv", replace depvar legend label nonumbers
	b(%9.3f) p star(* 0.10 ** 0.05 *** 0.01) nogaps drop(_cons)
	stats( N , fmt( %9.0g) labels( "Sample Size")) 
	title("Impacts") addnotes("""") ;
#delimit cr

** (1) Sharpened q-values **

*** Save p-values and get them in a data file to use 
mat y = J(4,3,.)

* Populate Outcome and Treatment 

* Outcome
forvalues j=1(1)1 {
mat y[`j',1]=1
mat y[`j'+1,1]=2
mat y[`j'+2,1]=3
mat y[`j'+3,1]=4
}

* Treatment
forvalues j=1(1)1 {
mat y[`j',2]=1
mat y[`j'+1,2]=1
mat y[`j'+2,2]=1
mat y[`j'+3,2]=1
}

local i=1
foreach var of varlist quality error criticalerror error_magnitude {
reghdfe `var' treatment, absorb(month id class teacher) vce(cluster id)
test treatment=0
mat y[`i',3]=r(p)
local i=`i'+1
}

mat colnames y = "Outcome" "Treatment" "p-value" 
mat2txt, matrix(y) saving("Tablepvals.xls") replace
preserve
drop _all
svmat double y
rename y1 outcome
rename y2 treatment
rename y3 pval
save "Tablepvals.dta", replace
restore


**** Now use Michael Anderson's code for sharpened q-values
preserve

use "Tablepvals.dta", clear
set more off

* Collect the total number of p-values tested

quietly sum pval
local totalpvals = r(N)

* Sort the p-values in ascending order and generate a variable that codes each p-value's rank

quietly gen int original_sorting_order = _n
quietly sort pval
quietly gen int rank = _n if pval~=.

* Set the initial counter to 1 

local qval = 1

* Generate the variable that will contain the BKY (2006) sharpened q-values

gen bky06_qval = 1 if pval~=.

* Set up a loop that begins by checking which hypotheses are rejected at q = 1.000, then checks which hypotheses are rejected at q = 0.999, then checks which hypotheses are rejected at q = 0.998, etc.  The loop ends by checking which hypotheses are rejected at q = 0.001.


while `qval' > 0 {
	* First Stage
	* Generate the adjusted first stage q level we are testing: q' = q/1+q
	local qval_adj = `qval'/(1+`qval')
	* Generate value q'*r/M
	gen fdr_temp1 = `qval_adj'*rank/`totalpvals'
	* Generate binary variable checking condition p(r) <= q'*r/M
	gen reject_temp1 = (fdr_temp1>=pval) if pval~=.
	* Generate variable containing p-value ranks for all p-values that meet above condition
	gen reject_rank1 = reject_temp1*rank
	* Record the rank of the largest p-value that meets above condition
	egen total_rejected1 = max(reject_rank1)

	* Second Stage
	* Generate the second stage q level that accounts for hypotheses rejected in first stage: q_2st = q'*(M/m0)
	local qval_2st = `qval_adj'*(`totalpvals'/(`totalpvals'-total_rejected1[1]))
	* Generate value q_2st*r/M
	gen fdr_temp2 = `qval_2st'*rank/`totalpvals'
	* Generate binary variable checking condition p(r) <= q_2st*r/M
	gen reject_temp2 = (fdr_temp2>=pval) if pval~=.
	* Generate variable containing p-value ranks for all p-values that meet above condition
	gen reject_rank2 = reject_temp2*rank
	* Record the rank of the largest p-value that meets above condition
	egen total_rejected2 = max(reject_rank2)

	* A p-value has been rejected at level q if its rank is less than or equal to the rank of the max p-value that meets the above condition
	replace bky06_qval = `qval' if rank <= total_rejected2 & rank~=.
	* Reduce q by 0.001 and repeat loop
	drop fdr_temp* reject_temp* reject_rank* total_rejected*
	local qval = `qval' - .001
}
	

quietly sort original_sorting_order
pause off
set more on

display "Code has completed."
display "Benjamini Krieger Yekutieli (2006) sharpened q-vals are in variable 'bky06_qval'"
display	"Sorting order is the same as the original vector of p-values"

keep outcome treatment pval bky06_qval
save "sharpenedqvals1.dta", replace

restore


** (2) MHTREG **

cap ssc install mhtreg

#delimit ;
mhtreg (quality treatment i.month i.id i.class i.teacher)
(error treatment i.month i.id i.class i.teacher)
(criticalerror treatment i.month i.id i.class i.teacher)
(error_magnitude treatment i.month i.id i.class i.teacher), 
seed(123) cluster(id) bootstrap(1000);
#delimit cr


** (3) WYOUNG **

* Install latest version
net install wyoung, from("https://raw.githubusercontent.com/reifjulian/wyoung/master") replace

gen constant=1
preserve 
#delimit;
wyoung quality error criticalerror error_magnitude, cmd(reghdfe OUTCOMEVAR treatment CONTROLVARS, absorb(month id class teacher)) familyp(treatment) controls("constant" "constant" "constant" "constant") seed(123) cluster(id) bootstraps(1000);
#delimit cr
restore

 
 

** (4) RWOLF **

cap ssc install rwolf2

rwolf2 (reghdfe quality treatment, absorb(month id class teacher) vce(cluster id)) ///
(reghdfe error treatment, absorb(month id class teacher) vce(cluster id)) ///
(reghdfe criticalerror treatment, absorb(month id class teacher) vce(cluster id)) ///
(reghdfe error_magnitude treatment, absorb(month id class teacher) vce(cluster id)), ///
indepvars(treatment, treatment, ///
treatment, treatment) usevalid seed(123) cluster(id) reps(1000)
 
 
*******************
**** Section 2 ****
*******************


use "`path_data'/data_main.dta", clear

gen treatment = after*experiment
gen interaction1 = treatment*gender
gen interaction2 = after*gender


eststo clear
reghdfe quality interaction1 interaction2 treatment, absorb(month id class teacher) vce(cluster id)
eststo table1_1
reghdfe error interaction1 interaction2 treatment, absorb(month id class teacher) vce(cluster id)
eststo table1_2
reghdfe criticalerror interaction1 interaction2 treatment, absorb(month id class teacher) vce(cluster id)
eststo table1_3
reghdfe error_magnitude interaction1 interaction2 treatment, absorb(month id class teacher) vce(cluster id)
eststo table1_4
#delimit ;
esttab table1_*  using "MHT_1.csv", replace depvar legend label nonumbers
	b(%9.3f) p star(* 0.10 ** 0.05 *** 0.01) nogaps drop(_cons)
	stats( N , fmt( %9.0g) labels( "Sample Size")) 
	title("Impacts") addnotes("""") ;
#delimit cr

** (1) Sharpened q-values **

*** Save p-values and get them in a data file to use 
mat y = J(4,3,.)

* Populate Outcome and Treatment 

* Outcome
forvalues j=1(1)1 {
mat y[`j',1]=1
mat y[`j'+1,1]=2
mat y[`j'+2,1]=3
mat y[`j'+3,1]=4
}

* Treatment
forvalues j=1(1)1 {
mat y[`j',2]=1
mat y[`j'+1,2]=1
mat y[`j'+2,2]=1
mat y[`j'+3,2]=1
}

local i=1
foreach var of varlist quality error criticalerror error_magnitude {
reghdfe `var' interaction1 interaction2 treatment, absorb(month id class teacher) vce(cluster id)
test interaction1=0
mat y[`i',3]=r(p)
local i=`i'+1
}

mat colnames y = "Outcome" "Treatment" "p-value" 
mat2txt, matrix(y) saving("Tablepvals.xls") replace
preserve
drop _all
svmat double y
rename y1 outcome
rename y2 treatment
rename y3 pval
save "Tablepvals.dta", replace
restore


**** Now use Michael Anderson's code for sharpened q-values
preserve

use "Tablepvals.dta", clear
set more off

* Collect the total number of p-values tested

quietly sum pval
local totalpvals = r(N)

* Sort the p-values in ascending order and generate a variable that codes each p-value's rank

quietly gen int original_sorting_order = _n
quietly sort pval
quietly gen int rank = _n if pval~=.

* Set the initial counter to 1 

local qval = 1

* Generate the variable that will contain the BKY (2006) sharpened q-values

gen bky06_qval = 1 if pval~=.

* Set up a loop that begins by checking which hypotheses are rejected at q = 1.000, then checks which hypotheses are rejected at q = 0.999, then checks which hypotheses are rejected at q = 0.998, etc.  The loop ends by checking which hypotheses are rejected at q = 0.001.


while `qval' > 0 {
	* First Stage
	* Generate the adjusted first stage q level we are testing: q' = q/1+q
	local qval_adj = `qval'/(1+`qval')
	* Generate value q'*r/M
	gen fdr_temp1 = `qval_adj'*rank/`totalpvals'
	* Generate binary variable checking condition p(r) <= q'*r/M
	gen reject_temp1 = (fdr_temp1>=pval) if pval~=.
	* Generate variable containing p-value ranks for all p-values that meet above condition
	gen reject_rank1 = reject_temp1*rank
	* Record the rank of the largest p-value that meets above condition
	egen total_rejected1 = max(reject_rank1)

	* Second Stage
	* Generate the second stage q level that accounts for hypotheses rejected in first stage: q_2st = q'*(M/m0)
	local qval_2st = `qval_adj'*(`totalpvals'/(`totalpvals'-total_rejected1[1]))
	* Generate value q_2st*r/M
	gen fdr_temp2 = `qval_2st'*rank/`totalpvals'
	* Generate binary variable checking condition p(r) <= q_2st*r/M
	gen reject_temp2 = (fdr_temp2>=pval) if pval~=.
	* Generate variable containing p-value ranks for all p-values that meet above condition
	gen reject_rank2 = reject_temp2*rank
	* Record the rank of the largest p-value that meets above condition
	egen total_rejected2 = max(reject_rank2)

	* A p-value has been rejected at level q if its rank is less than or equal to the rank of the max p-value that meets the above condition
	replace bky06_qval = `qval' if rank <= total_rejected2 & rank~=.
	* Reduce q by 0.001 and repeat loop
	drop fdr_temp* reject_temp* reject_rank* total_rejected*
	local qval = `qval' - .001
}
	

quietly sort original_sorting_order
pause off
set more on

display "Code has completed."
display "Benjamini Krieger Yekutieli (2006) sharpened q-vals are in variable 'bky06_qval'"
display	"Sorting order is the same as the original vector of p-values"

keep outcome treatment pval bky06_qval
save "sharpenedqvals1.dta", replace

restore


** (2) MHTREG **

cap ssc install mhtreg

#delimit ;
mhtreg (quality interaction1 interaction2 treatment i.month i.id i.class i.teacher)
(error interaction1 interaction2 treatment i.month i.id i.class i.teacher)
(criticalerror interaction1 interaction2 treatment i.month i.id i.class i.teacher)
(error_magnitude interaction1 interaction2 treatment i.month i.id i.class i.teacher), 
seed(123) cluster(id) bootstrap(1000);
#delimit cr


** (3) WYOUNG **

* Install latest version
net install wyoung, from("https://raw.githubusercontent.com/reifjulian/wyoung/master") replace

gen constant=1
preserve 
#delimit;
wyoung quality error criticalerror error_magnitude, cmd(reghdfe OUTCOMEVAR interaction1 CONTROLVARS, absorb(month id class teacher interaction2 treatment)) familyp(interaction1) controls("constant" "constant" "constant" "constant") seed(123) cluster(id) bootstraps(1000);
#delimit cr
restore
 
 

** (4) RWOLF **

cap ssc install rwolf2

rwolf2 (reghdfe quality interaction1 interaction2 treatment, absorb(month id class teacher) vce(cluster id)) ///
(reghdfe error interaction1 interaction2 treatment, absorb(month id class teacher) vce(cluster id)) ///
(reghdfe criticalerror interaction1 interaction2 treatment, absorb(month id class teacher) vce(cluster id)) ///
(reghdfe error_magnitude interaction1 interaction2 treatment, absorb(month id class teacher) vce(cluster id)), ///
indepvars(interaction1, interaction1, ///
interaction1, interaction1) usevalid seed(123) cluster(id) reps(1000)
 
