// =======
// Table A2: Alternative Fixed Eﬀects
// =======

** set path **
local path_data "$root/Data/"
local path_results "$root/Results/"

use "`path_data'/data_main.dta", clear

eststo clear

gen treatment = after*experiment
gen interaction = treatment*gender

gen time = real(string(month) + string(game)) 
 
* Column (1)
eststo: reghdfe quality after##experiment, absorb( time id class teacher) vce(cluster id)

* Column (2)
eststo: reghdfe quality after##experiment##gender, absorb( time id class teacher) vce(cluster id)

* Column (3)
eststo: reghdfe error after##experiment, absorb( time id class teacher) vce(cluster id)

* Column (4)
eststo: reghdfe error after##experiment##gender, absorb( time id class teacher) vce(cluster id)

* Column (5)
eststo: reghdfe criticalerror after##experiment, absorb( time id class teacher) vce(cluster id)

* Column (6)
eststo: reghdfe criticalerror after##experiment##gender, absorb( time id class teacher) vce(cluster id)

* Column (7)
eststo: reghdfe error_magnitude after##experiment, absorb( time id class teacher) vce(cluster id)

* Column (8)
eststo: reghdfe error_magnitude after##experiment##gender, absorb( time id class teacher) vce(cluster id)

esttab using "`path_results'/table_a2.csv", cells(b(star fmt(3)) p(par fmt(2))) starlevels(* .1 ** .05 *** .01) stats(r2 N, fmt(%5.3f %8.0fc)) label legend varlabels(_cons "Constant") replace

 
