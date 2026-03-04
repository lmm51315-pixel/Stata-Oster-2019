* Figure 9: Teachers' Emotions and Students' Outcome

** set path **
local path_data "$root/Data/"
local path_results "$root/Results/"

** set theme **
set scheme s1color

use "`path_data'/data_survey_learning.dta", clear


**********************
********  Q20  *******
**********************
preserve

generate q20_male = q20 if gender == 1 
generate q20_female = q20 if gender == 0
** drop the redundant variables
keep id q20*
** name-changing and reshape
rename q20 x1
rename q20_male x2
rename q20_female x3
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

catplot cat, over(which,label(labsize(huge))) percent(which) stack asyvars scheme(burd) l1title("") title("Positive emotions make you confident?", position(12) size(28pt)) legend(pos(3) col(3) size(small)) ytitle("") ylabel(-2 "0%" 23 "25%" 48 "50%" 73 "75%" 98 "100%", tposition(inside) labsize(huge)) 

graph save q20, replace

restore



**********************
********  Q21  *******
**********************
preserve

generate q21_male = q21 if gender == 1 
generate q21_female = q21 if gender == 0
** drop the redundant variables
keep id q21*
** name-changing and reshape
rename q21 x1
rename q21_male x2
rename q21_female x3
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

catplot cat, over(which,label(labsize(huge))) percent(which) stack asyvars scheme(burd) l1title("") title("Negative emotions make you confident?", position(12) size(28pt)) legend(pos(3) col(3) size(small)) ytitle("") ylabel(-2 "0%" 23 "25%" 48 "50%" 73 "75%" 98 "100%", tposition(inside) labsize(huge)) 


graph save q21, replace

restore



**********************
********  Q22  *******
**********************
preserve

generate q22_male = q22 if gender == 1 
generate q22_female = q22 if gender == 0
** drop the redundant variables
keep id q22*
** name-changing and reshape
rename q22 x1
rename q22_male x2
rename q22_female x3
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

catplot cat, over(which,label(labsize(huge))) percent(which) stack asyvars scheme(burd) l1title("") title("Positive emotions make you nervous?", position(12) size(28pt)) legend(pos(3) col(3) size(small)) ytitle("") ylabel(-2 "0%" 23 "25%" 48 "50%" 73 "75%" 98 "100%", tposition(inside) labsize(huge)) 


graph save q22, replace

restore


**********************
********  Q23  *******
**********************
preserve

generate q23_male = q23 if gender == 1 
generate q23_female = q23 if gender == 0
** drop the redundant variables
keep id q23*
** name-changing and reshape
rename q23 x1
rename q23_male x2
rename q23_female x3
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

catplot cat, over(which,label(labsize(huge))) percent(which) stack asyvars scheme(burd) l1title("") title("Negative emotions make you nervous?", position(12) size(28pt)) legend(pos(3) col(3) size(small)) ytitle("") ylabel(-2 "0%" 23 "25%" 48 "50%" 73 "75%" 98 "100%", tposition(inside) labsize(huge)) 

graph save q23, replace

restore


**********************
********  Q24  *******
**********************
preserve

generate q24_male = q24 if gender == 1 
generate q24_female = q24 if gender == 0
** drop the redundant variables
keep id q24*
** name-changing and reshape
rename q24 x1
rename q24_male x2
rename q24_female x3
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

catplot cat, over(which,label(labsize(huge))) percent(which) stack asyvars scheme(burd) l1title("") title("Positive emotions improve your concentration?", position(12) size(28pt)) legend(pos(3) col(3) size(small)) ytitle("") ylabel(-2 "0%" 23 "25%" 48 "50%" 73 "75%" 98 "100%", tposition(inside) labsize(huge)) 


graph save q24, replace

restore




**********************
********  Q25  *******
**********************
preserve

generate q25_male = q25 if gender == 1 
generate q25_female = q25 if gender == 0
** drop the redundant variables
keep id q25*
** name-changing and reshape
rename q25 x1
rename q25_male x2
rename q25_female x3
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

catplot cat, over(which,label(labsize(huge))) percent(which) stack asyvars scheme(burd) l1title("") title("Negative emotions improve your concentration?", position(12) size(28pt)) legend(pos(3) col(3) size(small)) ytitle("") ylabel(-2 "0%" 23 "25%" 48 "50%" 73 "75%" 98 "100%", tposition(inside) labsize(huge)) 


graph save q25, replace

restore



**********************
********  Q26  *******
**********************
preserve

generate q26_male = q26 if gender == 1 
generate q26_female = q26 if gender == 0
** drop the redundant variables
keep id q26*
** name-changing and reshape
rename q26 x1
rename q26_male x2
rename q26_female x3
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

catplot cat, over(which,label(labsize(huge))) percent(which) stack asyvars scheme(burd) l1title("") title("Positive emotions improve your willingness for advice?", position(12) size(28pt)) legend(pos(3) col(3) size(small)) ytitle("") ylabel(-2 "0%" 23 "25%" 48 "50%" 73 "75%" 98 "100%", tposition(inside) labsize(huge)) 


graph save q26, replace

restore





**********************
********  Q27  *******
**********************
preserve

generate q27_male = q27 if gender == 1 
generate q27_female = q27 if gender == 0
** drop the redundant variables
keep id q27*
** name-changing and reshape
rename q27 x1
rename q27_male x2
rename q27_female x3
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

catplot cat, over(which,label(labsize(huge))) percent(which) stack asyvars scheme(burd) l1title("") title("Negative emotions improve your willingness for advice?", position(12) size(28pt)) legend(pos(3) col(3) size(small)) ytitle("") ylabel(-2 "0%" 23 "25%" 48 "50%" 73 "75%" 98 "100%", tposition(inside) labsize(huge)) 


graph save q27, replace

restore


**********************
********  Q28  *******
**********************
preserve

generate q28_male = q28 if gender == 1 
generate q28_female = q28 if gender == 0
** drop the redundant variables
keep id q28*
** name-changing and reshape
rename q28 x1
rename q28_male x2
rename q28_female x3
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

catplot cat, over(which,label(labsize(huge))) percent(which) stack asyvars scheme(burd) l1title("") title("Positive emotions improve your interests?", position(12) size(28pt)) legend(pos(3) col(3) size(small)) ytitle("") ylabel(-2 "0%" 23 "25%" 48 "50%" 73 "75%" 98 "100%", tposition(inside) labsize(huge)) 


graph save q28, replace

restore





**********************
********  Q29  *******
**********************
preserve

generate q29_male = q29 if gender == 1 
generate q29_female = q29 if gender == 0
** drop the redundant variables
keep id q29*
** name-changing and reshape
rename q29 x1
rename q29_male x2
rename q29_female x3
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

catplot cat, over(which,label(labsize(huge))) percent(which) stack asyvars scheme(burd) l1title("") title("Negative emotions improve your interests?", position(12) size(28pt)) legend(pos(3) col(3) size(small)) ytitle("") ylabel(-2 "0%" 23 "25%" 48 "50%" 73 "75%" 98 "100%", tposition(inside) labsize(huge)) 


graph save q29, replace

restore



grc1leg q20.gph q21.gph q22.gph q23.gph q24.gph q25.gph q26.gph q27.gph q28.gph q29.gph, cols(2) iscale(0.25) ysize(12) xsize(4) ///
imargin(0 0 0 0) ycommon xcommon 
graph export "`path_results'/figure9.eps" , as(eps) replace
graph export "`path_results'/figure9.png" , as(png) replace
graph export "`path_results'/figure9.pdf" , as(pdf) replace
 

 
 

foreach v in q20.gph q21.gph q22.gph q23.gph q24.gph q25.gph q26.gph q27.gph q28.gph q29.gph{
	erase `v'
}
