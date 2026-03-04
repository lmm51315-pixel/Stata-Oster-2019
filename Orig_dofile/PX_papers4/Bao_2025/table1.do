// =======
// Table 1
// =======

** set path **
local path_data "$root/Data/"
local path_results "$root/Results/"

use "`path_data'/data_main.dta", clear


* Panel A: Student Data
preserve
collapse  age study rank gender experiment, by (id)

	sum age
	ttest age, by(experiment) unequal
	sum study
	ttest study, by(experiment) unequal
	sum rank
	ttest rank, by(experiment) unequal
	sum gender
	ttest gender, by(experiment) unequal

restore

* Panel B: Teacher Data
preserve
collapse  teacher_age teacher_experience teacher_gender experiment, by (teacher)

	sum teacher_age
	ttest teacher_age, by(experiment) unequal
	sum teacher_experience
	ttest teacher_experience, by(experiment) unequal
	sum teacher_gender
	ttest teacher_gender, by(experiment) unequal

restore

* Panel C: Game Data

	sum quality
	ttest quality, by(experiment) unequal
	sum quality_pre
	ttest quality_pre, by(experiment) unequal
	sum quality_mid
	ttest quality_mid, by(experiment) unequal
	sum quality_end
	ttest quality_end, by(experiment) unequal
	sum error
	ttest error, by(experiment) unequal
	sum criticalerror
	ttest criticalerror, by(experiment) unequal
	sum error_magnitude
	ttest error_magnitude, by(experiment) unequal
	sum outcome
	ttest outcome, by(experiment) unequal
	sum white
	ttest white, by(experiment) unequal
	
	

* Panel D: Video Data

	sum visual_positive
	ttest visual_positive, by(experiment) unequal
	sum visual_negative
	ttest visual_negative, by(experiment) unequal
	sum vocal_positive
	ttest vocal_positive, by(experiment) unequal
	sum vocal_negative
	ttest vocal_negative, by(experiment) unequal
	sum verbal
	ttest verbal, by(experiment) unequal

