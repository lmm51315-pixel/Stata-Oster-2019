* Figure C4: Student-perceived gender identity of the AI teacher

** set path **
local path_data "$root/Data/"
local path_results "$root/Results/"

** set theme **
set scheme s1color

** read data **
use "`path_data'/data_survey_cartoon.dta", clear

 
**********************
********  q7  ********
**********************
preserve

generate q7_male = q7 if gender == 1 
generate q7_female = q7 if gender == 0
** drop the redundant variables
keep id q7*
drop id
gen id = _n
** name-changing and reshape
rename q7 x1
rename q7_male x2
rename q7_female x3
reshape long x, i(id) j(which)
** tabulate and generate dummy
tab x which
tab x, gen(xx)
reshape long xx, i(id which) j(cat)
label define  cat 1 "Male" 2 "Female" 3 "Neutral"
label values cat cat
label define  which 1 "Overall" 2 "Boys" 3 "Girls"
label values which which
keep if xx ~= . & xx ~= 0
** figure q7
catplot cat, over(which,label(labsize(large))) percent(which) stack asyvars scheme(burd) l1title("") title("Gender Identity Based on Apperance", size(20pt) position(12)) legend(pos(3) col(3) size(small)) ytitle("") ylabel(-2 "0%" 23 "25%" 48 "50%" 73 "75%" 98 "100%", tposition(inside) labsize(large)) 
graph save q7, replace
 
restore 

**********************
********  q8  ********
**********************
 
preserve

generate q8_male = q8 if gender == 1 
generate q8_female = q8 if gender == 0
** drop the redundant variables
keep id q8*
drop id
gen id = _n
** name-changing and reshape
rename q8 x1
rename q8_male x2
rename q8_female x3
reshape long x, i(id) j(which)
** tabulate and generate dummy
tab x which
tab x, gen(xx)
reshape long xx, i(id which) j(cat)
label define  cat 1 "Male" 2 "Female" 3 "Neutral"
label values cat cat
label define  which 1 "Overall" 2 "Boys" 3 "Girls"
label values which which
keep if xx ~= . & xx ~= 0
** figure q8
catplot cat, over(which,label(labsize(large))) percent(which) stack asyvars scheme(burd) l1title("") title("Gender Identity Based on Sound", size(20pt) position(12)) legend(pos(3) col(3) size(small)) ytitle("") ylabel(-2 "0%" 23 "25%" 48 "50%" 73 "75%" 98 "100%", tposition(inside) labsize(large)) 
graph save q8, replace

restore
 

 
grc1leg q7.gph q8.gph, cols(2) ///
iscale(0.5) ysize(8) xsize(4) ///
imargin(0 0 0 0) ycommon xcommon 
graph export "`path_results'/figure_c4.eps" , as(eps) replace
graph export "`path_results'/figure_c4.png" , as(png) replace
graph export "`path_results'/figure_c4.pdf" , as(pdf) replace

erase q7.gph
erase q8.gph


