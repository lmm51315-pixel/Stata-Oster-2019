* Figure 4: Win/Lose by gender

** set path **
local path_data "$root/Data/"
local path_results "$root/Results/"

** set theme **
set scheme s1color

use "`path_data'/data_main.dta", clear

* Panel A
preserve
keep if experiment == 0 & gender == 0
collapse (mean) mean = outcome (sem) sem = outcome, by(month)
gen upper0 = mean+sem
gen lower0 = mean-sem
rename mean mean0
gen x = _n - 5
save figure3a.dta, replace 
restore

* Panel B
preserve
keep if experiment == 0 & gender == 1
collapse (mean) mean = outcome (sem) sem = outcome, by(month)
gen upper1 = mean+sem
gen lower1 = mean-sem
rename mean mean1
gen x = _n - 5
save figure3b.dta, replace 
restore

* Panel C
preserve
keep if experiment == 1 & gender == 0
collapse (mean) mean = outcome (sem) sem = outcome, by(month)
gen upper2 = mean+sem
gen lower2 = mean-sem
rename mean mean2
gen x = _n - 5
save figure3c.dta, replace 
restore

* Panel D
preserve
keep if experiment == 1 & gender == 1
collapse (mean) mean = outcome (sem) sem = outcome, by(month)
gen upper3 = mean+sem
gen lower3 = mean-sem
rename mean mean3
gen x = _n - 5
save figure3d.dta, replace 
restore


use figure3a, clear
merge 1:1 x using figure3b
drop _merge
merge 1:1 x using figure3c
drop _merge
merge 1:1 x using figure3d
save figure3, replace

* Plot
use figure3, clear
graph twoway rcap upper0 lower0 x , lcolor(red) lpattern(dash) /// 
	||     connected mean0 x, msymbol(circle_hollow) lcolor(red) lpattern(dash) mc(red) /// 
	||		rcap upper1 lower1 x , lcolor(blue) lpattern(dash) /// 
	||     connected mean1 x, msymbol(circle_hollow) lcolor(blue) lpattern(solid) mc(blue) /// 
	|| 	   rcap upper2 lower2 x , lcolor(red) lpattern(dash) /// 
	||     connected mean2 x, msymbol(circle) lcolor(red) lpattern(dash) mc(red) /// 
	|| 	   rcap upper3 lower3 x , lcolor(blue) lpattern(dash) /// 
	||     connected mean3 x, msymbol(circle) lcolor(blue) lpattern(solid) mc(blue) /// 	
	ytitle(Winning Rate) xtitle("") xline(0, lpattern(dash) lcolor(gray)) ylabel(0.46(0.02)0.60) xlabel(-4(1)5) legend(order(2 "Control Group (Girls)" 4 "Control Group (Boys)" 6 "Treated Group (Girls)" 8 "Treated Group (Boys)"))
	
graph export "`path_results'/figure4.eps" , as(eps) replace
graph export "`path_results'/figure4.png" , as(png) replace
graph export "`path_results'/figure4.pdf" , as(pdf) replace
	

erase figure3a.dta
erase figure3b.dta
erase figure3c.dta
erase figure3d.dta
erase figure3.dta	
