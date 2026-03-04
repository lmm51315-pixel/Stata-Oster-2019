* Figure C5: Student-perceived effectiveness of teaching formats

** set path **
local path_data "$root/Data/"
local path_results "$root/Results/"

** set theme **
set scheme s1color

** read data **
use "`path_data'/data_survey_learning.dta", clear

 
**********************
********  Q4  ********
**********************
preserve


generate q4_male = q4 if gender == 1 
generate q4_female = q4 if gender == 0
** drop the redundant variables
keep id q4*
drop id
gen id = _n
** name-changing and reshape
rename q4 x1
rename q4_male x2
rename q4_female x3
reshape long x, i(id) j(which)
** tabulate and generate dummy
tab x which
tab x, gen(xx)
reshape long xx, i(id which) j(cat)
label define  cat 1 "Online Teaching" 2 "Face-to-face Teaching" 3 "Similar" 4 "Don't Know"
label values cat cat
label define  which 1 "Overall" 2 "Boys" 3 "Girls"
label values which which
keep if xx ~= . & xx ~= 0
** figure q4
catplot cat, over(which,label(labsize(medium))) percent(which) stack asyvars scheme(burd) l1title("") title("Which teaching format more beneficial for learning?", position(12)) legend(position(6) col(4) size(small)) ytitle("") ylabel(-2 "0%" 23 "25%" 48 "50%" 73 "75%" 98 "100%", tposition(inside) labsize(medium)) 
graph export "`path_results'/figure_c5.eps" , as(eps) replace
graph export "`path_results'/figure_c5.png" , as(png) replace
graph export "`path_results'/figure_c5.pdf" , as(pdf) replace
 
restore 



// erase q4.gph


