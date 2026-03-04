// =======
// Table 6
// =======

** set path **
local path_data "$root/Data/"
local path_results "$root/Results/"

use "`path_data'/data_main.dta", clear

gen treatment = after*experiment

gen time = real(string(month) + string(game)) 
tsset id time

* past performance

sort id time

by id: gen lag1=quality[_n-1]
by id: gen lag3=(quality[_n-1] + quality[_n-2] + quality[_n-3])/3
by id: gen lag7=(quality[_n-1] + quality[_n-2] + quality[_n-3] + quality[_n-4] + quality[_n-5] + quality[_n-6] + quality[_n-7])/7


keep if treatment == 1

eststo clear

* Column (1)
eststo: reghdfe quality visual_positive lag*, absorb(month id class teacher) vce(cluster id teacher)

* Column (2)
eststo: reghdfe quality visual_negative lag*, absorb(month id class teacher) vce(cluster id teacher)

* Column (3)
eststo: reghdfe quality vocal_positive lag*, absorb(month id class teacher) vce(cluster id teacher)

* Column (4)
eststo: reghdfe quality vocal_negative lag*, absorb(month id class teacher) vce(cluster id teacher)

* Column (5)
eststo: reghdfe quality verbal lag*, absorb(month id class teacher) vce(cluster id teacher)

* Column (6)
eststo: reghdfe quality visual_positive visual_negative vocal_positive vocal_negative verbal lag*, absorb(month id class teacher) vce(cluster id teacher)

* Column (7)
eststo: reghdfe quality visual_positive visual_negative vocal_positive vocal_negative verbal lag* if gender == 0, absorb(month id class teacher) vce(cluster id teacher)

* Column (8)
eststo: reghdfe quality visual_positive visual_negative vocal_positive vocal_negative verbal lag* if gender == 1, absorb(month id class teacher) vce(cluster id teacher)
 
*** we use the following esttab command to get the standardized coefficients 
esttab using "`path_results'/table6a.csv", beta starlevels(* .1 ** .05 *** .01) stats(r2 N, fmt(%5.3f %8.0fc)) label legend varlabels(_cons "Constant") replace

*** we use the following esttab command to get the p-value for standardized coefficients 
esttab using "`path_results'/table6b.csv", cells(b(star fmt(3)) p(par fmt(2))) starlevels(* .1 ** .05 *** .01) stats(r2 N, fmt(%5.3f %8.0fc)) label legend varlabels(_cons "Constant") replace

 


 
