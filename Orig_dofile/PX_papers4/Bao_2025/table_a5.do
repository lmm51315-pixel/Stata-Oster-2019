// =======
// Table A5: Opponent Controls
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
* Note: we show the average partial effects in the main context, while the esttab records the coefficients.
preserve
gen time = real(string(month) + string(game)) 
tsset id time
eststo: logitfe outcome treatment interaction*, jack ss2
restore

* Column (2)
eststo: reghdfe quality after##experiment##gender i.opponent_gender i.opponent_rank, absorb(month id class teacher) vce(cluster id)

* Column (3)
eststo: reghdfe error after##experiment##gender i.opponent_gender i.opponent_rank, absorb(month id class teacher) vce(cluster id)

* Column (4)
eststo: reghdfe criticalerror after##experiment##gender i.opponent_gender i.opponent_rank, absorb(month id class teacher) vce(cluster id)

* Column (5)
eststo: reghdfe error_magnitude after##experiment##gender i.opponent_gender i.opponent_rank, absorb(month id class teacher) vce(cluster id)

esttab using "`path_results'/table_a5.csv", cells(b(star fmt(3)) p(par fmt(2))) starlevels(* .1 ** .05 *** .01) stats(r2 N, fmt(%5.3f %8.0fc)) label legend varlabels(_cons "Constant") replace
 
