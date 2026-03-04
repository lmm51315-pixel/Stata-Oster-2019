// =======
// Table C1: Average Move Quality at different stages
// =======

** set path **
local path_data "$root/Data/"
local path_results "$root/Results/"

use "`path_data'/data_main.dta", clear

eststo clear

gen treatment = after*experiment
gen interaction1 = treatment*gender
gen interaction2 = after*gender

* Column (1)
eststo: reghdfe quality_pre after##experiment, absorb(month id class teacher) vce(cluster id)

* Column (2)
eststo: reghdfe quality_pre after##experiment##gender, absorb(month id class teacher) vce(cluster id)

* Column (3)
eststo: reghdfe quality_mid after##experiment, absorb(month id class teacher) vce(cluster id)

* Column (4)
eststo: reghdfe quality_mid after##experiment##gender, absorb(month id class teacher) vce(cluster id)

* Column (5)
eststo: reghdfe quality_end after##experiment, absorb(month id class teacher) vce(cluster id)

* Column (6)
eststo: reghdfe quality_end after##experiment##gender, absorb(month id class teacher) vce(cluster id)


esttab using "`path_results'/table_c1.csv", cells(b(star fmt(3)) p(par fmt(2))) starlevels(* .1 ** .05 *** .01) stats(r2 N, fmt(%5.3f %8.0fc)) label legend varlabels(_cons "Constant") replace






