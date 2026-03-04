* Figure C2: Dynamic Eﬀects of AI Training on Number of Critical Errors

** set path **
local path_data "$root/Data/"
local path_results "$root/Results/"

** set theme **
set scheme s1color


** Boys and Girls
use "`path_data'/data_main.dta", clear
eststo clear
tabulate month, generate(dum)  

forvalues i = 1(1)10 {
	generate interaction`i' = experiment*dum`i'
}

eststo: reghdfe criticalerror interaction1-interaction4 interaction6-interaction10, absorb(month id class teacher) vce(cluster id)

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

graph twoway rcap upper lower x , lcolor(lavender) lpattern(dash) /// 
	||     connected coef x, msymbol(circle) lcolor(lavender) lpattern(solid) mc(lavender) /// 
	ytitle("") xtitle("")  yline(0, lpattern(dash) lcolor(gray)) xline(0, lpattern(dash) lcolor(gray)) xlabel(-4(1)5)  legend(off) ytitle("Treatment Effect Dynamics") title("")
graph save dynamic1.gph, replace



** Girls
use "`path_data'/data_main.dta", clear
eststo clear
tabulate month, generate(dum)  

forvalues i = 1(1)10 {
	generate interaction`i' = experiment*dum`i'
}

eststo: reghdfe criticalerror interaction1-interaction4 interaction6-interaction10 if gender == 0, absorb(month id class teacher) vce(cluster id)

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
keep upper lower coef x

save temp_female, replace


** Boys
use "`path_data'/data_main.dta", clear
eststo clear
tabulate month, generate(dum)  

forvalues i = 1(1)10 {
	generate interaction`i' = experiment*dum`i'
}

eststo: reghdfe criticalerror interaction1-interaction4 interaction6-interaction10 if gender == 1, absorb(month id class teacher) vce(cluster id)

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
keep upper lower coef x

save temp_male, replace


** Plot
use temp_male, clear
rename upper upper1
rename lower lower1
rename coef coef1

merge 1:1 x using temp_female
graph twoway rcap upper1 lower1 x , lcolor(blue) lpattern(dash) /// 
	||     connected coef1 x, msymbol(circle) lcolor(blue) lpattern(solid) mc(blue) /// 
	|| 	   rcap upper lower x , lcolor(red) lpattern(dash) /// 
	||     connected coef x, msymbol(circle) lcolor(red) lpattern(dash) mc(red) /// 
	ytitle("") xtitle("")  yline(0, lpattern(dash) lcolor(gray)) xline(0, lpattern(dash) lcolor(gray)) xlabel(-4(1)5) ytitle("Treatment Effect Dynamics by Gender") title("") legend(order(2 "Boys" 4 "Girls"))
graph save dynamic2.gph, replace



gr combine dynamic1.gph dynamic2.gph, col(1) xsize(7) ysize(9) 
graph export "`path_results'/figure_c2.eps", as(eps) replace
graph export "`path_results'/figure_c2.png" , as(png) replace
graph export "`path_results'/figure_c2.pdf" , as(pdf) replace

erase dynamic1.gph
erase dynamic2.gph
erase temp_male.dta
erase temp_female.dta
