// =======
// Table B2: Gender and Emotional Status
// =======

** set path **
local path_data "$root/Data/"
local path_results "$root/Results/"

use "`path_data'/data_main.dta", clear

eststo clear


gen treatment = after*experiment
gen time = real(string(month) + string(game)) 

tsset id time

* past performance
sort id time
by id: gen lag1=quality[_n-1]
by id: gen lag3=(quality[_n-1] + quality[_n-2] + quality[_n-3])/3
by id: gen lag7=(quality[_n-1] + quality[_n-2] + quality[_n-3] + quality[_n-4] + quality[_n-5] + quality[_n-6] + quality[_n-7])/7


*** Section 1: Human Teachers ***

preserve
keep if treatment == 0

* Column (1)
eststo: reghdfe visual_positive gender age study rank lag* if teacher_gender == 1, absorb(month class teacher) vce(cluster id teacher)

* Column (2)
eststo: reghdfe visual_positive gender age study rank lag* if teacher_gender == 0, absorb(month class teacher) vce(cluster id teacher)

* Column (4)
eststo: reghdfe visual_negative gender age study rank lag* if teacher_gender == 1, absorb(month class teacher) vce(cluster id teacher)

* Column (5)
eststo: reghdfe visual_negative gender age study rank lag* if teacher_gender == 0, absorb(month class teacher) vce(cluster id teacher)

* Column (7)
eststo: reghdfe vocal_positive gender age study rank  lag* if teacher_gender == 1, absorb(month class teacher) vce(cluster id teacher)

* Column (8)
eststo: reghdfe vocal_positive gender age study rank  lag* if teacher_gender == 0, absorb(month class teacher) vce(cluster id teacher)

* Column (10)
eststo: reghdfe vocal_negative gender age study rank  lag* if teacher_gender == 1, absorb(month class teacher) vce(cluster id teacher)

* Column (11)
eststo: reghdfe vocal_negative gender age study rank  lag* if teacher_gender == 0, absorb(month class teacher) vce(cluster id teacher)

* Column (13)
eststo: reghdfe verbal gender age study rank  lag* if teacher_gender == 1, absorb(month class teacher) vce(cluster id teacher)

* Column (14)
eststo: reghdfe verbal gender age study rank  lag* if teacher_gender == 0, absorb(month class teacher) vce(cluster id teacher)

restore

 
*** Section 2: AI Teachers ***

preserve
keep if treatment == 1

* Column (3)
eststo: reghdfe visual_positive gender age study rank lag*, absorb(month class teacher) vce(cluster id teacher)

* Column (6)
eststo: reghdfe visual_negative gender age study rank lag*, absorb(month class teacher) vce(cluster id teacher)

* Column (9)
eststo: reghdfe vocal_positive gender age study rank lag*, absorb(month class teacher) vce(cluster id teacher)

* Column (12)
eststo: reghdfe vocal_negative gender age study rank lag*, absorb(month class teacher) vce(cluster id teacher)

* Column (15)
eststo: reghdfe verbal gender age study rank lag*, absorb(month class teacher) vce(cluster id teacher)

  
esttab using "`path_results'/table_b2.csv", cells(b(star fmt(3)) p(par fmt(2))) starlevels(* .1 ** .05 *** .01) stats(r2 N, fmt(%5.3f %8.0fc)) label legend varlabels(_cons "Constant") replace
 


 
