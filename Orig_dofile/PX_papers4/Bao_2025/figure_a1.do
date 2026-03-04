
* Figure A1: Self-control in human- and AI-led classes

** set path **
local path_data "$root/Data/"
local path_results "$root/Results/"

** set theme **
set scheme s1color

** read data **
use "`path_data'/data_survey_learning.dta", clear


**********************
********  Q30  *******
**********************
preserve

generate q30_male = q30 if gender == 1 
generate q30_female = q30 if gender == 0
** drop the redundant variables
keep id q30*
** name-changing and reshape
rename q30 x1
rename q30_male x2
rename q30_female x3
reshape long x, i(id) j(which)
** tabulate and generate dummy
tab x which
tab x, gen(xx)
reshape long xx, i(id which) j(cat)
label define  cat 1 "Never" 2 "Rarely" 3 "Sometimes" 4 "Often" 5 "Very Often" 6 "Always"
label values cat cat
label define  which 1 "Overall" 2 "Boys" 3 "Girls"
label values which which
keep if xx ~= . & xx ~= 0
** figure q30
catplot cat, over(which) percent(which) stack asyvars scheme(burd) l1title("") title("Absent-minded in a typical human-led class", size(medium) position(12)) legend(pos(3) col(3))
graph save q30, replace

restore


**********************
********  Q31  *******
**********************
preserve

generate q31_male = q31 if gender == 1 
generate q31_female = q31 if gender == 0
** drop the redundant variables
keep id q31*
** name-changing and reshape
rename q31 x1
rename q31_male x2
rename q31_female x3
reshape long x, i(id) j(which)
** tabulate and generate dummy
tab x which
tab x, gen(xx)
reshape long xx, i(id which) j(cat)
label define  cat 1 "Never" 2 "Rarely" 3 "Sometimes" 4 "Often" 5 "Very Often" 6 "Always"
label values cat cat
label define  which 1 "Overall" 2 "Boys" 3 "Girls"
label values which which
keep if xx ~= . & xx ~= 0
** figure q31
catplot cat, over(which) percent(which) stack asyvars scheme(burd) l1title("") title("Absent-minded in a typical AI-led class", size(medium) position(12)) legend(pos(3) col(3))
graph save q31, replace

restore


 


grc1leg q30.gph q31.gph, cols(2) ///
imargin(0 0 0 0) ycommon xcommon 
graph export "`path_results'/figure_a1.eps" , as(eps) replace
graph export "`path_results'/figure_a1.png" , as(png) replace
graph export "`path_results'/figure_a1.pdf" , as(pdf) replace



erase q30.gph
erase q31.gph
