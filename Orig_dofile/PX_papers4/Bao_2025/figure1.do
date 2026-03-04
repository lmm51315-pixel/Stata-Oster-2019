* Figure 1: Win/Lose

** set path **
local path_data "$root/Data/"
local path_results "$root/Results/"

** set theme **
set scheme s1color

use "`path_data'/data_main.dta", clear

* Panel A
preserve
keep if experiment == 0
collapse (mean) mean = outcome (sem) sem = outcome, by(month)
gen upper = mean+sem
gen lower = mean-sem
gen x = _n - 5
save figure1a.dta, replace 
restore

* Panel B
preserve
keep if experiment == 1
collapse (mean) mean = outcome (sem) sem = outcome, by(month)
gen upper = mean+sem
gen lower = mean-sem
gen x = _n - 5
save figure1b.dta, replace 
restore

* Plot
use figure1a, clear
drop sem
rename upper upper1
rename lower lower1
rename mean mean1
merge 1:1 x using figure1b
 	
graph twoway rcap upper1 lower1 x , lcolor(sandb) lpattern(dash) /// 
	||     connected mean1 x, msymbol(circle) lcolor(sandb) lpattern(solid) mc(sandb) /// 
	|| 	   rcap upper lower x , lcolor(ebblue) lpattern(dash) /// 
	||     connected mean x, msymbol(triangle) lcolor(ebblue) lpattern(solid) mc(ebblue) /// 
	ytitle(Winning Rate) xtitle("") xline(0, lpattern(dash) lcolor(gray)) ylabel(0.46(0.04)0.60) xlabel(-4(1)5) legend(order(2 "Control Group" 4 "Treated Group"))

	
graph export "`path_results'/figure1.eps" , as(eps) replace
graph export "`path_results'/figure1.png" , as(png) replace
graph export "`path_results'/figure1.pdf" , as(pdf) replace
	

erase figure1a.dta
erase figure1b.dta
