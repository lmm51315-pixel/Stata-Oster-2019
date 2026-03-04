* Figure 3: Evolution of treatment effects

** set path **
local path_data "$root/Data/"
local path_results "$root/Results/"

** set theme **
set scheme s1color

use "`path_data'/data_main.dta", clear

* (1) data clean
eststo clear
tabulate month, generate(dum)  

forvalues i = 1(1)10 {
	generate interaction`i' = experiment*dum`i'
}

eststo: reghdfe quality interaction1-interaction4 interaction6-interaction10, absorb(month id class teacher) vce(cluster id)

regsave,tstat pval ci

drop if _n == 10
moss var, match("([0-9]+)")  regex
drop _count _pos1

rename _match1 date
destring date, replace

set obs 10
replace date = 5 in 10
replace coef = 0 in 10
replace stderr = 0 in 10

sort date
gen upper = coef + stderr*1.96
gen lower = coef - stderr*1.96
gen x = date - 5


* (2) plot 
graph twoway rcap upper lower x , lcolor(lavender) lpattern(dash) /// 
	||     connected coef x, msymbol(circle) lcolor(lavender) lpattern(solid) mc(lavender) /// 
	ytitle("") xtitle("")  yline(0, lpattern(dash) lcolor(gray)) xline(0, lpattern(dash) lcolor(gray)) xlabel(-4(1)5)  legend(off) ytitle("Treatment Effect Dynamics") title("")

	
graph export "`path_results'/figure3.eps" , as(eps) replace
graph export "`path_results'/figure3.png" , as(png) replace
graph export "`path_results'/figure3.pdf" , as(pdf) replace
