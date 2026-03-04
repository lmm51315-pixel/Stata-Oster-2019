// =======
// Table B3: Raw coefficients
// =======

** set path **
local path_data "$root/Data/"
local path_results "$root/Results/"

use "`path_data'/data_main.dta", clear

gen treatment = after*experiment
gen time = real(string(month) + string(game)) 
tsset id time
sort id time

by id: gen lag1=quality[_n-1]
by id: gen lag3=(quality[_n-1] + quality[_n-2] + quality[_n-3])/3
by id: gen lag7=(quality[_n-1] + quality[_n-2] + quality[_n-3] + quality[_n-4] + quality[_n-5] + quality[_n-6] + quality[_n-7])/7

keep if treatment == 0

eststo clear

eststo: reghdfe quality i.gender##c.(visual_positive) lag*, absorb(month class teacher) vce(cluster id teacher)

eststo: reghdfe quality i.gender##c.(visual_negative) lag*, absorb(month class teacher) vce(cluster id teacher)

eststo: reghdfe quality i.gender##c.(vocal_positive) lag*, absorb(month class teacher) vce(cluster id teacher)

eststo: reghdfe quality i.gender##c.(vocal_negative) lag*, absorb(month class teacher) vce(cluster id teacher)

eststo: reghdfe quality i.gender##c.(verbal) lag*, absorb(month class teacher) vce(cluster id teacher)

esttab using "`path_results'/table_b3.csv", cells(b(star fmt(3)) p(par fmt(2))) starlevels(* .1 ** .05 *** .01) stats(r2 N, fmt(%5.3f %8.0fc)) label legend varlabels(_cons "Constant") replace
