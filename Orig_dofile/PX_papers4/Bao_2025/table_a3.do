// =======
// Table A3: Different Clustering
// =======

** set path **
local path_data "$root/Data/"
local path_results "$root/Results/"

use "`path_data'/data_main.dta", clear

eststo clear

gen treatment = after*experiment
gen interaction = treatment*gender


* Column (1)
eststo: reghdfe quality after##experiment, absorb(month id class teacher) vce(cluster id teacher)

* Column (2)
eststo: reghdfe quality after##experiment##gender, absorb(month id class teacher) vce(cluster id teacher)

* Column (3)
eststo: reghdfe error after##experiment, absorb(month id class teacher) vce(cluster id teacher)

* Column (4)
eststo: reghdfe error after##experiment##gender, absorb(month id class teacher) vce(cluster id teacher)

* Column (5)
eststo: reghdfe criticalerror after##experiment, absorb(month id class teacher) vce(cluster id teacher)

* Column (6)
eststo: reghdfe criticalerror after##experiment##gender, absorb(month id class teacher) vce(cluster id teacher)

* Column (7)
eststo: reghdfe error_magnitude after##experiment, absorb(month id class teacher) vce(cluster id teacher)

* Column (8)
eststo: reghdfe error_magnitude after##experiment##gender, absorb(month id class teacher) vce(cluster id teacher)

esttab using "`path_results'/table_a3.csv", cells(b(star fmt(3)) p(par fmt(2))) starlevels(* .1 ** .05 *** .01) stats(r2 N, fmt(%5.3f %8.0fc)) label legend varlabels(_cons "Constant") replace

