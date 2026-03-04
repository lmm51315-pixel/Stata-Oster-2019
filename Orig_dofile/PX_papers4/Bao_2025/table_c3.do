// =======
// Table C3: Regression results on cartoon survey
// =======
 
** set path **
local path_data "$root/Data/"
local path_results "$root/Results/"

use "`path_data'/data_survey_cartoon.dta", clear

eststo clear

* Column (1)
eststo: reghdfe visual_positive q3 , noabsorb vce(cluster id)

* Column (2)
eststo: reghdfe visual_positive q3 , absorb(id) vce(cluster id)

* Column (3)
eststo: reghdfe vocal_positive q4 , noabsorb vce(cluster id)

* Column (4)
eststo: reghdfe vocal_positive q4 , absorb(id) vce(cluster id)

* Column (5)
eststo: reghdfe verbal q5 , noabsorb vce(cluster id)

* Column (6)
eststo: reghdfe verbal q5 , absorb(id) vce(cluster id)


esttab using "`path_results'/table_c3.csv", cells(b(star fmt(3)) p(par fmt(2))) starlevels(* .1 ** .05 *** .01) stats(r2 N, fmt(%5.3f %8.0fc)) label legend varlabels(_cons "Constant") replace
