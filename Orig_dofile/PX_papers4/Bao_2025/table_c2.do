// =======
// Table C2: Results for Subgroups
// =======

** set path **
local path_data "$root/Data/"
local path_results "$root/Results/"

use "`path_data'/data_main.dta", clear


foreach var of varlist quality error criticalerror error_magnitude{

eststo clear

* Column (1)
preserve

gen treatment = after*experiment

gen dum1 = 0
replace dum1 = 1 if age <10

gen dum2 = 0
replace dum2 = 1 if age >=10 & age <13

gen dum3 = 0
replace dum3 = 1 if age >=13

forvalues i = 1(1)3 {
	generate interaction`i' = treatment*dum`i'
}

eststo: reghdfe `var' interaction* , absorb(month id class teacher) vce(cluster id)
eststo: reghdfe `var' interaction* if gender == 0, absorb(month id class teacher) vce(cluster id)
eststo: reghdfe `var' interaction* if gender == 1, absorb(month id class teacher) vce(cluster id)
restore


* Column (2)
preserve

gen treatment = after*experiment


tabulate study, generate(dum)
forvalues i = 1(1)4 {
	generate interaction`i' = treatment*dum`i'
}

eststo: reghdfe `var' interaction* , absorb(month id class teacher) vce(cluster id)
eststo: reghdfe `var' interaction* if gender == 0, absorb(month id class teacher) vce(cluster id)
eststo: reghdfe `var' interaction* if gender == 1, absorb(month id class teacher) vce(cluster id)

restore

* Column (3)
preserve

gen treatment = after*experiment


tabulate rank, generate(dum)
forvalues i = 1(1)5 {
	generate interaction`i' = treatment*dum`i'
}

eststo: reghdfe `var' interaction* , absorb(month id class teacher) vce(cluster id)
eststo: reghdfe `var' interaction* if gender == 0, absorb(month id class teacher) vce(cluster id)
eststo: reghdfe `var' interaction* if gender == 1, absorb(month id class teacher) vce(cluster id)

restore

esttab using "`path_results'/table_c2_`var'.csv", cells(b(star fmt(3)) p(par fmt(2))) starlevels(* .1 ** .05 *** .01) stats(r2 N, fmt(%5.3f %8.0fc)) label legend varlabels(_cons "Constant") replace
	
	

}
 


