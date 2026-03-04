// =======
// Table A1: Sample Selection of Videos
// =======

** set path **
local path_data "$root/Data/"
local path_results "$root/Results/"

use "`path_data'/data_main.dta", clear

eststo clear

eststo: reghdfe video gender, absorb(month) vce(cluster id teacher)

eststo: reghdfe video age, absorb(month) vce(cluster id teacher)

eststo: reghdfe video study, absorb(month) vce(cluster id teacher)

eststo: reghdfe video rank, absorb(month) vce(cluster id teacher)

eststo: reghdfe video teacher_gender, absorb(month) vce(cluster id teacher)

eststo: reghdfe video teacher_age, absorb(month) vce(cluster id teacher)

eststo: reghdfe video teacher_experience, absorb(month) vce(cluster id teacher)

eststo: reghdfe video gender age study rank teacher_gender teacher_age teacher_experience, absorb(month) vce(cluster id teacher)
 
esttab using "`path_results'/table_a1.csv", cells(b(star fmt(3)) p(par fmt(2))) starlevels(* .1 ** .05 *** .01) stats(r2 N, fmt(%5.3f %8.0fc)) label legend varlabels(_cons "Constant") replace
