clear

** Set Your Path Here **
global root "."

** Set Path **
local adir "$root/Code"

********************************************
** MAIN CONTENT (TAKES ABOUT TWO MINUTES) **
********************************************

** Check and Install Stata Packages **

// * NOTE: package grc1leg can only be net installed as follows:
net install grc1leg, from("http://www.stata.com/users/vwiggins")

local packages_main "reghdfe logitfe moss catplot regsave"

foreach pkg in `packages_main' {
    capture which `pkg'
    if _rc {
        ssc install `pkg'
    }
    else {
        display "`pkg' is already installed."
    }
}


** Begin Replication **

foreach num of numlist 1/9 {
	do "`adir'/figure`num'"
}

foreach num of numlist 1/6 {
	do "`adir'/table`num'"
}


*********************************************** 
** INTERNET APPENDIX (TAKES ABOUT TWO HOURS) **
***********************************************

** Check and Install Stata Packages **

local packages_appendix "psacalc oaxaca mhtreg rwolf2" 

// * NOTE: package wyoung can only be net installed as follows:
net install wyoung, from("https://raw.githubusercontent.com/reifjulian/wyoung/master") replace 

foreach pkg in `packages_appendix' {
    capture which `pkg'
    if _rc {
        ssc install `pkg'
    }
    else {
        display "`pkg' is already installed."
    }
}

** Begin Replication **

foreach num of numlist 1/1 {
	do "`adir'/figure_a`num'"
}

foreach num of numlist 1/5 {
	do "`adir'/figure_c`num'"
}

foreach num of numlist 1/10 {
	do "`adir'/table_a`num'"
}

foreach num of numlist 1/3 {
	do "`adir'/table_b`num'"
}

foreach num of numlist 1/3 {
	do "`adir'/table_c`num'"
}

foreach num of numlist 1/1 {
	do "`adir'/table_d`num'"
}
