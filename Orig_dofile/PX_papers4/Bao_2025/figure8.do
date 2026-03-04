* Figure 8: Students’ perception of teachers’ emotions

** set path **
local path_data "$root/Data/"
local path_results "$root/Results/"

** set theme **
set scheme s1color

use "`path_data'/data_survey_learning.dta", clear


**********************
********  Q14  *******
**********************
preserve

generate q14_male = q14 if gender == 1 
generate q14_female = q14 if gender == 0
** drop the redundant variables
keep id q14*
** name-changing and reshape
rename q14 x1
rename q14_male x2
rename q14_female x3
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

catplot cat, over(which,label(labsize(vhuge))) percent(which) stack asyvars scheme(burd) l1title("") title("Can you sense human emotions in class?", position(12) size(36pt)) legend(pos(3) col(3) size(small)) ytitle("") ylabel(-2 "0%" 23 "25%" 48 "50%" 73 "75%" 98 "100%", tposition(inside) labsize(vhuge)) 

graph save q14, replace

restore


**********************
********  Q15  *******
**********************
preserve

generate q15_male = q15 if gender == 1 
generate q15_female = q15 if gender == 0
** drop the redundant variables
keep id q15*
** name-changing and reshape
rename q15 x1
rename q15_male x2
rename q15_female x3
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

catplot cat, over(which,label(labsize(vhuge))) percent(which) stack asyvars scheme(burd) l1title("") title("Can you sense AI emotions in class?", position(12) size(36pt)) legend(pos(3) col(3) size(small)) ytitle("") ylabel(-2 "0%" 23 "25%" 48 "50%" 73 "75%" 98 "100%", tposition(inside) labsize(vhuge)) 


graph save q15, replace

restore

 

**********************
********  Q16  *******
**********************
preserve

generate q16_male = q16 if gender == 1 
generate q16_female = q16 if gender == 0
** drop the redundant variables
keep id q16*
** name-changing and reshape
rename q16 x1
rename q16_male x2
rename q16_female x3
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

catplot cat, over(which,label(labsize(vhuge))) percent(which) stack asyvars scheme(burd) l1title("") title("Human emotions are gender-biased?", position(12) size(36pt)) legend(pos(3) col(3) size(small)) ytitle("") ylabel(-2 "0%" 23 "25%" 48 "50%" 73 "75%" 98 "100%", tposition(inside) labsize(vhuge)) 


graph save q16, replace

restore




**********************
********  Q17  *******
**********************
preserve

generate q17_male = q17 if gender == 1 
generate q17_female = q17 if gender == 0
** drop the redundant variables
keep id q17*
** name-changing and reshape
rename q17 x1
rename q17_male x2
rename q17_female x3
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

catplot cat, over(which,label(labsize(vhuge))) percent(which) stack asyvars scheme(burd) l1title("") title("AI emotions are gender-biased?", position(12) size(36pt)) legend(pos(3) col(3) size(small)) ytitle("") ylabel(-2 "0%" 23 "25%" 48 "50%" 73 "75%" 98 "100%", tposition(inside) labsize(vhuge)) 


graph save q17, replace

restore

* combine

grc1leg q14.gph q15.gph q16.gph q17.gph, cols(2) ///
iscale(0.25) ysize(8) xsize(4) imargin(0 0 0 0) ycommon xcommon 
graph save "figure9a" , replace
// graph export "figure9a.eps" , as(eps) replace
// graph export "figure9a.png" , as(png) replace
// graph export "figure9a.pdf" , as(pdf) replace



**********************
********  Q18  *******
**********************
preserve

generate q18_male = q18 if gender == 1 
generate q18_female = q18 if gender == 0
** drop the redundant variables
keep id q18*
** name-changing and reshape
rename q18 x1
rename q18_male x2
rename q18_female x3
reshape long x, i(id) j(which)
** tabulate and generate dummy
tab x which
tab x, gen(xx)
reshape long xx, i(id which) j(cat)
label define  cat 1 "Positive" 2 "Negative" 3 "No Impact" 4 "Don't Know"
label values cat cat
label define  which 1 "Overall" 2 "Boys" 3 "Girls" 
label values which which
keep if xx ~= . & xx ~= 0
// for question 
generate identifier = 18
save "question18_processed.dta", replace 

restore




**********************
********  Q19  *******
**********************

preserve

generate q19_male = q19 if gender == 1 
generate q19_female = q19 if gender == 0
** drop the redundant variables
keep id q19*
** name-changing and reshape
rename q19 x1
rename q19_male x2
rename q19_female x3
reshape long x, i(id) j(which)
** tabulate and generate dummy
tab x which
tab x, gen(xx)
reshape long xx, i(id which) j(cat)
replace cat = cat + 2
label define  cat 1 "Positive" 2 "Negative" 3 "No Impact" 4 "Don't Know"
label values cat cat
label define  which 1 "Overall" 2 "Boys" 3 "Girls"
label values which which
keep if xx ~= . & xx ~= 0
// for question 
generate identifier = 19
// appned
append using question18_processed.dta


catplot cat which, percent(which identifier) by(identifier, note("")) stack asyvars scheme(burd) l1title("") title("AI gender-biased emotions affect learning?", position(12)) legend(pos(3) col(4) size(small)) ytitle("") ylabel(-2 "0%" 23 "25%" 48 "50%" 73 "75%" 98 "100%", tposition(inside)) subtitle("") ysize(3) xsize(10) name("myshitgraph", replace)

graph display myshitgraph, xsize(15) ysize(3) 

graph save "figure9b" , replace


restore


** Combine them and fine tune the position and size

graph combine figure9a.gph figure9b.gph, col(1) ycommon xcommon 
gr_edit plotregion1.graph2.SetAspectRatio 0.2 // graph2 edits
gr_edit plotregion1.graph2.plotregion1.title[1].style.editstyle size(medium) editcopy // title[1] size
gr_edit plotregion1.graph2.plotregion1.grpaxis[1].style.editstyle majorstyle(tickstyle(textstyle(size(small)))) editcopy // grpaxis[1] size
gr_edit plotregion1.graph2.plotregion1.scaleaxis[1].style.editstyle majorstyle(tickstyle(textstyle(size(small)))) editcopy
// scaleaxis[1] size
gr_edit plotregion1.graph1.yoffset = -3.5
gr_edit plotregion1.graph1.Edit , cmd(.set_rows = 2) cmd(.set_cols =0 ) 
// graph1 edits
gr_edit plotregion1.graph2.yoffset = 0.55
gr_edit plotregion1.graph2.Edit , cmd(.set_rows = 2) cmd(.set_cols =0 ) 
// graph2 edits
gr_edit plotregion1.graph2.style.editstyle boxstyle(shadestyle(color(none))) editcopy
gr_edit plotregion1.graph2.Edit , cmd(.set_rows = 1) cmd(.set_cols =0 ) 
gr_edit plotregion1.graph2.style.editstyle boxstyle(linestyle(color(none))) editcopy
gr_edit plotregion1.graph2.style.editstyle boxstyle(shadestyle(color(none))) editcopy
// graph2 color
gr_edit plotregion1.graph1.plotregion1.graph3.style.editstyle boxstyle(shadestyle(color(none))) editcopy 
// graph3 color
gr_edit plotregion1.graph1.plotregion1.graph1.style.editstyle boxstyle(shadestyle(color(none))) editcopy
// graph1 color
gr_edit plotregion1.graph1.plotregion1.graph2.style.editstyle boxstyle(shadestyle(color(none))) editcopy
// graph2 color
gr_edit plotregion1.graph1.plotregion1.graph4.style.editstyle boxstyle(shadestyle(color(none))) editcopy
// graph4 color
gr_edit plotregion1.graph2.plotregion1.title[1].text = {}
gr_edit plotregion1.graph2.plotregion1.title[1].text.Arrpush Human gender-biased emotions affect learning?
// title[1] edits

graph export "`path_results'/figure8.eps" , as(eps) replace
graph export "`path_results'/figure8.png" , as(png) replace
graph export "`path_results'/figure8.pdf" , as(pdf) replace



foreach v in figure9a.gph figure9b.gph q14.gph q15.gph q16.gph q17.gph question18_processed.dta{
	erase `v'
}







