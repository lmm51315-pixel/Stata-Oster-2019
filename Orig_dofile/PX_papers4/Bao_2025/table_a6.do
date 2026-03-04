// =======
// Table A6: Performance and Opponent Gender 
// =======

** set path **
local path_data "$root/Data/"
local path_results "$root/Results/"

use "`path_data'/data_main.dta", clear

eststo clear

** Boys **
keep if gender == 1

gen treatment = after*experiment
gen interaction = treatment*gender

* Column (1)
* Note: we show the average partial effects in the main context, while the esttab records the coefficients.
preserve
gen time = real(string(month) + string(game)) 
tsset id time
eststo: logitfe outcome i.opponent_gender i.opponent_rank, jack ss2
restore

* Column (2)
* Note: we show the average partial effects in the main context, while the esttab records the coefficients.
preserve
gen time = real(string(month) + string(game)) 
tsset id time
eststo: logitfe outcome i.opponent_gender i.opponent_rank if treatment == 0, jack ss2
restore

* Column (3)
* Note: we show the average partial effects in the main context, while the esttab records the coefficients.
preserve
gen time = real(string(month) + string(game)) 
tsset id time
eststo: logitfe outcome i.opponent_gender i.opponent_rank if treatment == 1, jack ss2
restore

* Column (7)
eststo: reghdfe quality i.opponent_gender i.opponent_rank, absorb(month id class teacher) vce(cluster id)

* Column (8)
eststo: reghdfe quality i.opponent_gender i.opponent_rank if treatment == 0, absorb(month id class teacher) vce(cluster id)

* Column (9)
eststo: reghdfe quality i.opponent_gender i.opponent_rank if treatment == 1, absorb(month id class teacher) vce(cluster id) 

** Girls **
use "`path_data'/data_main.dta", clear

keep if gender == 0

gen treatment = after*experiment
gen interaction = treatment*gender

* Column (4)
* Note: we show the average partial effects in the main context, while the esttab records the coefficients.
preserve
gen time = real(string(month) + string(game)) 
tsset id time
eststo: logitfe outcome i.opponent_gender i.opponent_rank, jack ss2
restore

* Column (5)
* Note: we show the average partial effects in the main context, while the esttab records the coefficients.
preserve
gen time = real(string(month) + string(game)) 
tsset id time
eststo: logitfe outcome i.opponent_gender i.opponent_rank if treatment == 0, jack ss2
restore

* Column (6)
* Note: we show the average partial effects in the main context, while the esttab records the coefficients.
preserve
gen time = real(string(month) + string(game)) 
tsset id time
eststo: logitfe outcome i.opponent_gender i.opponent_rank if treatment == 1, jack ss2
restore

* Column (10)
eststo: reghdfe quality i.opponent_gender i.opponent_rank, absorb(month id class teacher) vce(cluster id)

* Column (11)
eststo: reghdfe quality i.opponent_gender i.opponent_rank if treatment == 0, absorb(month id class teacher) vce(cluster id)

* Column (12)
eststo: reghdfe quality i.opponent_gender i.opponent_rank if treatment == 1, absorb(month id class teacher) vce(cluster id)

esttab using "`path_results'/table_a6.csv", cells(b(star fmt(3)) p(par fmt(2))) starlevels(* .1 ** .05 *** .01) stats(r2 N, fmt(%5.3f %8.0fc)) label legend varlabels(_cons "Constant") replace
 

 
 

