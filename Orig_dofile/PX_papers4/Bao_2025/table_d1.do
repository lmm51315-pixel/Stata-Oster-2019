// =======
// Table D1: BO decomposition
// =======

** set path **
local path_data "$root/Data/"
local path_results "$root/Results/"

use "`path_data'/data_main.dta", clear

eststo clear


gen treatment = after*experiment 
keep if treatment == 0

oaxaca quality visual_positive visual_negative vocal_positive vocal_negative verbal, by(gender) weight(1)
eststo t`table'_col1

oaxaca quality visual_positive visual_negative vocal_positive vocal_negative verbal, by(gender) weight(0)
eststo t`table'_col2

oaxaca quality visual_positive visual_negative vocal_positive vocal_negative verbal, by(gender) omega
eststo t`table'_col3

oaxaca quality visual_positive visual_negative vocal_positive vocal_negative verbal, by(gender) pooled
eststo t`table'_col4

esttab using "`path_results'/table_d1.csv", cells(b(star fmt(3)) p(par fmt(2))) starlevels(* .1 ** .05 *** .01) stats(r2 N, fmt(%5.3f %8.0fc)) label legend varlabels(_cons "Constant") replace
