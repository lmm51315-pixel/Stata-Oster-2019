// =======
// Table A8: Attendance
// =======

** set path **
local path_data "$root/Data/"
local path_results "$root/Results/"

use "`path_data'/data_main.dta", clear

eststo clear

label define after 0 "Before" 1 "After"
egen count_month = count(game), by(id month)

* Column (1)
eststo: poisson count_month after if experiment == 1 

* Column (2)
eststo: poisson count_month after i.month if experiment == 1 

* Column (3)
eststo: poisson count_month after i.id i.month i.class i.teacher if experiment == 1 

* Column (4)
eststo: poisson count_month after if experiment == 0

* Column (5)
eststo: poisson count_month after i.month if experiment == 0

* Column (6)
eststo: poisson count_month after i.id i.month i.class i.teacher if experiment == 0

esttab using "`path_results'/table_a8.csv", cells(b(star fmt(3)) p(par fmt(2))) starlevels(* .1 ** .05 *** .01) stats(r2 N, fmt(%5.3f %8.0fc)) label legend varlabels(_cons "Constant") replace
