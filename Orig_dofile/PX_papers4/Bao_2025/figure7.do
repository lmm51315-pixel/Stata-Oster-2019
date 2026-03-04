* Figure 7: Survey results on human-AI distinctions

** set path **
local path_data "$root/Data/"
local path_results "$root/Results/"

** set theme **
set scheme s1color

use "`path_data'/data_survey_learning.dta", clear




**********************
********  Q5  ********
**********************
preserve

generate q5_male = q5 if gender == 1 
generate q5_female = q5 if gender == 0
** drop the redundant variables
keep id q5*
** name-changing and reshape
rename q5 x1
rename q5_male x2
rename q5_female x3
reshape long x, i(id) j(which)
** tabulate and generate dummy
tab x which
tab x, gen(xx)
reshape long xx, i(id which) j(cat)
label define  cat 1 "Yes" 2 "No" 3 "Don't Know"
label values cat cat
label define  which 1 "Overall" 2 "Boys" 3 "Girls"
label values which which
keep if xx ~= . & xx ~= 0
** figure q5
catplot cat, over(which,label(labsize(huge))) percent(which) stack asyvars scheme(burd) l1title("") title("AI better in game analysis?", position(12) size(28pt)) legend(pos(3) col(3) size(small)) ytitle("") ylabel(-2 "0%" 23 "25%" 48 "50%" 73 "75%" 98 "100%", tposition(inside) labsize(huge)) 
graph save q5, replace 

restore 


	
**********************
********  Q6  ********
**********************
 
preserve

generate q6_male = q6 if gender == 1 
generate q6_female = q6 if gender == 0
** drop the redundant variables
keep id q6*
** name-changing and reshape
rename q6 x1
rename q6_male x2
rename q6_female x3
reshape long x, i(id) j(which)
** tabulate and generate dummy
tab x which
tab x, gen(xx)
reshape long xx, i(id which) j(cat)
label define  cat 1 "Yes" 2 "No" 3 "Don't Know"
label values cat cat
label define  which 1 "Overall" 2 "Boys" 3 "Girls"
label values which which
keep if xx ~= . & xx ~= 0
** figure q6
catplot cat, over(which,label(labsize(huge))) percent(which) stack asyvars scheme(burd) l1title("") title("Better game analysis improves learning?", position(12) size(28pt)) legend(pos(3) col(3) size(small)) ytitle("") ylabel(-2 "0%" 23 "25%" 48 "50%" 73 "75%" 98 "100%", tposition(inside) labsize(huge)) 
graph save q6, replace

restore
 

**********************
********  Q7  ********
**********************

preserve

generate q7_male = q7 if gender == 1 
generate q7_female = q7 if gender == 0
** drop the redundant variables
keep id q7*
** name-changing and reshape
rename q7 x1
rename q7_male x2
rename q7_female x3
reshape long x, i(id) j(which)
** tabulate and generate dummy
tab x which
tab x, gen(xx)
reshape long xx, i(id which) j(cat)
label define  cat 1 "Yes" 2 "No" 3 "Don't Know"
label values cat cat
label define  which 1 "Overall" 2 "Boys" 3 "Girls"
label values which which
keep if xx ~= . & xx ~= 0
** figure q7
catplot cat, over(which,label(labsize(huge))) percent(which) stack asyvars scheme(burd) l1title("") title("AI provides better interactive display?", position(12) size(28pt)) legend(pos(3) col(3) size(small)) ytitle("") ylabel(-2 "0%" 23 "25%" 48 "50%" 73 "75%" 98 "100%", tposition(inside) labsize(huge)) 
graph save q7, replace

restore




**********************
********  Q8  *******
**********************
preserve

generate q8_male = q8 if gender == 1 
generate q8_female = q8 if gender == 0
** drop the redundant variables
keep id q8*
** name-changing and reshape
rename q8 x1
rename q8_male x2
rename q8_female x3
reshape long x, i(id) j(which)
** tabulate and generate dummy
tab x which
tab x, gen(xx)
reshape long xx, i(id which) j(cat)
label define  cat 1 "Yes" 2 "No" 3 "Don't Know"
label values cat cat
label define  which 1 "Overall" 2 "Boys" 3 "Girls"
label values which which
keep if xx ~= . & xx ~= 0
** figure q8
catplot cat, over(which,label(labsize(huge))) percent(which) stack asyvars scheme(burd) l1title("") title("Better interactive display improves learning?", position(12) size(28pt)) legend(pos(3) col(3) size(small)) ytitle("") ylabel(-2 "0%" 23 "25%" 48 "50%" 73 "75%" 98 "100%", tposition(inside) labsize(huge)) 
graph save q8, replace

restore





**********************
********  Q9  *******
**********************

preserve

generate q9_male = q9 if gender == 1 
generate q9_female = q9 if gender == 0
** drop the redundant variables
keep id q9*
** name-changing and reshape
rename q9 x1
rename q9_male x2
rename q9_female x3
reshape long x, i(id) j(which)
** tabulate and generate dummy
tab x which
tab x, gen(xx)
reshape long xx, i(id which) j(cat)
label define  cat 1 "Yes" 2 "No" 3 "Don't Know"
label values cat cat
label define  which 1 "Overall" 2 "Boys" 3 "Girls"
label values which which
keep if xx ~= . & xx ~= 0
** figure q9
catplot cat, over(which,label(labsize(huge))) percent(which) stack asyvars scheme(burd) l1title("") title("Better interactive display helps concentrate?", position(12) size(28pt)) legend(pos(3) col(3) size(small)) ytitle("") ylabel(-2 "0%" 23 "25%" 48 "50%" 73 "75%" 98 "100%", tposition(inside) labsize(huge)) 
graph save q9, replace

restore





**********************
********  Q10  ********
**********************
preserve

generate q10_male = q10 if gender == 1 
generate q10_female = q10 if gender == 0
** drop the redundant variables
keep id q10*
** name-changing and reshape
rename q10 x1
rename q10_male x2
rename q10_female x3
reshape long x, i(id) j(which)
** tabulate and generate dummy
tab x which
tab x, gen(xx)
reshape long xx, i(id which) j(cat)
label define  cat 1 "Yes" 2 "No" 3 "Don't Know"
label values cat cat
label define  which 1 "Overall" 2 "Boys" 3 "Girls"
label values which which
keep if xx ~= . & xx ~= 0
** figure q10
catplot cat, over(which,label(labsize(huge))) percent(which) stack asyvars scheme(burd) l1title("") title("AI provides more relevant information?", position(12) size(28pt)) legend(pos(3) col(3) size(small)) ytitle("") ylabel(-2 "0%" 23 "25%" 48 "50%" 73 "75%" 98 "100%", tposition(inside) labsize(huge)) 
graph save q10, replace

restore




**********************
********  Q11  ********
**********************
 
preserve

generate q11_male = q11 if gender == 1 
generate q11_female = q11 if gender == 0
** drop the redundant variables
keep id q11*
** name-changing and reshape
rename q11 x1
rename q11_male x2
rename q11_female x3
reshape long x, i(id) j(which)
** tabulate and generate dummy
tab x which
tab x, gen(xx)
reshape long xx, i(id which) j(cat)
label define  cat 1 "Yes" 2 "No" 3 "Don't Know"
label values cat cat
label define  which 1 "Overall" 2 "Boys" 3 "Girls"
label values which which
keep if xx ~= . & xx ~= 0
** figure q11
catplot cat, over(which,label(labsize(huge))) percent(which) stack asyvars scheme(burd) l1title("") title("More relevant information improves learning?", position(12) size(28pt)) legend(pos(3) col(3) size(small)) ytitle("") ylabel(-2 "0%" 23 "25%" 48 "50%" 73 "75%" 98 "100%", tposition(inside) labsize(huge)) 
graph save q11, replace

restore





**********************
********  Q12  ********
**********************

preserve

generate q12_male = q12 if gender == 1 
generate q12_female = q12 if gender == 0
** drop the redundant variables
keep id q12*
** name-changing and reshape
rename q12 x1
rename q12_male x2
rename q12_female x3
reshape long x, i(id) j(which)
** tabulate and generate dummy
tab x which
tab x, gen(xx)
reshape long xx, i(id which) j(cat)
label define  cat 1 "Yes" 2 "No" 3 "Don't Know"
label values cat cat
label define  which 1 "Overall" 2 "Boys" 3 "Girls"
label values which which
keep if xx ~= . & xx ~= 0
** figure q12
catplot cat, over(which,label(labsize(huge))) percent(which) stack asyvars scheme(burd) l1title("") title("AI has more attractive appearance?", position(12) size(28pt)) legend(pos(3) col(3) size(small)) ytitle("") ylabel(-2 "0%" 23 "25%" 48 "50%" 73 "75%" 98 "100%", tposition(inside) labsize(huge)) 
graph save q12, replace

restore


**********************
********  Q13  ********
**********************
 
preserve

generate q13_male = q13 if gender == 1 
generate q13_female = q13 if gender == 0
** drop the redundant variables
keep id q13*
** name-changing and reshape
rename q13 x1
rename q13_male x2
rename q13_female x3
reshape long x, i(id) j(which)
** tabulate and generate dummy
tab x which
tab x, gen(xx)
reshape long xx, i(id which) j(cat)
label define  cat 1 "Yes" 2 "No" 3 "Don't Know"
label values cat cat
label define  which 1 "Overall" 2 "Boys" 3 "Girls"
label values which which
keep if xx ~= . & xx ~= 0
** figure q13
catplot cat, over(which,label(labsize(huge))) percent(which) stack asyvars scheme(burd) l1title("") title("More attractive appearance improves learning?", position(12) size(28pt)) legend(pos(3) col(3) size(small)) ytitle("") ylabel(-2 "0%" 23 "25%" 48 "50%" 73 "75%" 98 "100%", tposition(inside) labsize(huge)) 
graph save q13, replace

restore



grc1leg q5.gph q6.gph q10.gph q11.gph q12.gph q13.gph q7.gph q8.gph, cols(2) ///
iscale(0.25) ysize(12) xsize(4) imargin(0 0 0 0) ycommon xcommon 
graph export "`path_results'/figure7.eps" , as(eps) replace
graph export "`path_results'/figure7.png" , as(png) replace
graph export "`path_results'/figure7.pdf" , as(pdf) replace


foreach v in q5.gph q6.gph q10.gph q11.gph q12.gph q13.gph q7.gph q9.gph q8.gph{
	erase `v'
}
