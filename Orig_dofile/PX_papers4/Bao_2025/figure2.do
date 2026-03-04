* Figure 2: Four measures

** set path **
local path_data "$root/Data/"
local path_results "$root/Results/"

** set theme **
set scheme s1color

use "`path_data'/data_main.dta", clear

**********************************
** Part 1: Average Move Quality 
**********************************

* Panel A
preserve
keep if experiment == 0
collapse (mean) mean = quality (sem) sem = quality, by(month)
gen upper = mean+sem
gen lower = mean-sem
gen x = _n - 5
save figure1a.dta, replace 
restore

* Panel B
preserve
keep if experiment == 1
collapse (mean) mean = quality (sem) sem = quality, by(month)
gen upper = mean+sem
gen lower = mean-sem
gen x = _n - 5
save figure1b.dta, replace 
restore


use figure1a, clear
drop sem
rename upper upper1
rename lower lower1
rename mean mean1
merge 1:1 x using figure1b
save figure1, replace


graph twoway rcap upper1 lower1 x , lcolor(sandb) lpattern(dash) /// 
	||     connected mean1 x, msymbol(circle) lcolor(sandb) lpattern(solid) mc(sandb) /// 
	|| 	   rcap upper lower x , lcolor(ebblue) lpattern(dash) /// 
	||     connected mean x, msymbol(triangle) lcolor(ebblue) lpattern(solid) mc(ebblue) /// 
	ytitle(Average Move Quality) xtitle("") xline(0, lpattern(dash) lcolor(gray)) ylabel(,format(%4.1f)) xlabel(-4(1)5) legend(order(2 "Control Group" 4 "Treated Group"))
	
graph save figure3a.gph, replace


**********************************
** Part 2: Errors 
**********************************

use "`path_data'/data_main.dta", clear

* Panel A
preserve
keep if experiment == 0
collapse (mean) mean = error (sem) sem = error, by(month)
gen upper = mean+sem
gen lower = mean-sem
gen x = _n - 5
save figure1a.dta, replace 
restore

* Panel B
preserve
keep if experiment == 1
collapse (mean) mean = error (sem) sem = error, by(month)
gen upper = mean+sem
gen lower = mean-sem
gen x = _n - 5
save figure1b.dta, replace 
restore

use figure1a, clear
drop sem
rename upper upper1
rename lower lower1
rename mean mean1
merge 1:1 x using figure1b
save figure1, replace

	
graph twoway rcap upper1 lower1 x , lcolor(sandb) lpattern(dash) /// 
	||     connected mean1 x, msymbol(circle) lcolor(sandb) lpattern(solid) mc(sandb) /// 
	|| 	   rcap upper lower x , lcolor(ebblue) lpattern(dash) /// 
	||     connected mean x, msymbol(triangle) lcolor(ebblue) lpattern(solid) mc(ebblue) /// 
	ytitle(Number of Errors) xtitle("") xline(0, lpattern(dash) lcolor(gray)) ylabel(,format(%4.1f)) xlabel(-4(1)5) legend(order(2 "Control Group" 4 "Treated Group"))

graph save figure3b.gph, replace
	

**********************************
** Part 3: Critical Errors
**********************************

use "`path_data'/data_main.dta", clear

* Panel A
preserve
keep if experiment == 0
collapse (mean) mean = criticalerror (sem) sem = criticalerror, by(month)
gen upper = mean+sem
gen lower = mean-sem
gen x = _n - 5
save figure1a.dta, replace 
restore

* Panel B
preserve
keep if experiment == 1
collapse (mean) mean = criticalerror (sem) sem = criticalerror, by(month)
gen upper = mean+sem
gen lower = mean-sem
gen x = _n - 5
save figure1b.dta, replace 
restore

use figure1a, clear
drop sem
rename upper upper1
rename lower lower1
rename mean mean1
merge 1:1 x using figure1b
save figure1, replace

graph twoway rcap upper1 lower1 x , lcolor(sandb) lpattern(dash) /// 
	||     connected mean1 x, msymbol(circle) lcolor(sandb) lpattern(solid) mc(sandb) /// 
	|| 	   rcap upper lower x , lcolor(ebblue) lpattern(dash) /// 
	||     connected mean x, msymbol(triangle) lcolor(ebblue) lpattern(solid) mc(ebblue) /// 
	ytitle(Number of Critical Errors) xtitle("") xline(0, lpattern(dash) lcolor(gray)) ylabel(,format(%4.1f)) xlabel(-4(1)5) legend(order(2 "Control Group" 4 "Treated Group"))
	
graph save figure3c.gph, replace
	
	
**********************************
** Part 4: Error Magnitude
**********************************

use "`path_data'/data_main.dta", clear

* Panel A
preserve
keep if experiment == 0
collapse (mean) mean = error_magnitude (sem) sem = error_magnitude, by(month)
gen upper = mean+sem
gen lower = mean-sem
gen x = _n - 5
save figure1a.dta, replace 
restore

* Panel B
preserve
keep if experiment == 1
collapse (mean) mean = error_magnitude (sem) sem = error_magnitude, by(month)
gen upper = mean+sem
gen lower = mean-sem
gen x = _n - 5
save figure1b.dta, replace 
restore


use figure1a, clear
drop sem
rename upper upper1
rename lower lower1
rename mean mean1
merge 1:1 x using figure1b
save figure1, replace


graph twoway rcap upper1 lower1 x , lcolor(sandb) lpattern(dash) /// 
	||     connected mean1 x, msymbol(circle) lcolor(sandb) lpattern(solid) mc(sandb) /// 
	|| 	   rcap upper lower x , lcolor(ebblue) lpattern(dash) /// 
	||     connected mean x, msymbol(triangle) lcolor(ebblue) lpattern(solid) mc(ebblue) /// 
	ytitle(Error Magnitude) xtitle("") xline(0, lpattern(dash) lcolor(gray)) ylabel(,format(%4.1f)) xlabel(-4(1)5) legend(order(2 "Control Group" 4 "Treated Group"))	

graph save figure3d.gph, replace
	
erase figure1a.dta
erase figure1b.dta
erase figure1.dta	
	
** Combine Four Subfigures

grc1leg figure3a.gph figure3b.gph figure3c.gph figure3d.gph
graph export "`path_results'/figure2.eps" , as(eps) replace
graph export "`path_results'/figure2.png" , as(png) replace
graph export "`path_results'/figure2.pdf" , as(pdf) replace

erase figure3a.gph 
erase figure3b.gph 
erase figure3c.gph 
erase figure3d.gph
