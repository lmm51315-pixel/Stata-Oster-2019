

use "data_main.dta", clear


* pca
pca visual_positive visual_negative vocal_positive vocal_negative verbal
predict pc1 pc2 pc3, score

areg quality pc2 teacher_gender teacher_age teacher_experience age study gender, absorb(month)


** Part 1: min(2R^2,1)

bs r(beta), rep(100): psacalc beta pc2, rmax(0.40) delta(1) model(areg quality pc2 teacher_gender teacher_age teacher_experience age study gender, absorb(month))

bs r(beta), rep(100): psacalc beta pc2, rmax(0.40) delta(1.5) model(areg quality pc2 teacher_gender teacher_age teacher_experience age study gender, absorb(month))

psacalc delta pc2, rmax(0.40) beta(0) model(areg quality pc2 teacher_gender teacher_age teacher_experience age study gender, absorb(month))


** Part 2: min(2.2R^2,1)

bs r(beta), rep(100): psacalc beta pc2, rmax(0.44) delta(1) model(areg quality pc2 teacher_gender teacher_age teacher_experience age study gender, absorb(month))

bs r(beta), rep(100): psacalc beta pc2, rmax(0.44) delta(1.5) model(areg quality pc2 teacher_gender teacher_age teacher_experience age study gender, absorb(month))

psacalc delta pc2, rmax(0.44) beta(0) model(areg quality pc2 teacher_gender teacher_age teacher_experience age study gender, absorb(month))

** Part 3: min(3R^2,1)

bs r(beta), rep(100): psacalc beta pc2, rmax(0.60) delta(1) model(areg quality pc2 teacher_gender teacher_age teacher_experience age study gender, absorb(month))

bs r(beta), rep(100): psacalc beta pc2, rmax(0.60) delta(1.5) model(areg quality pc2 teacher_gender teacher_age teacher_experience age study gender, absorb(month))

psacalc delta pc2, rmax(0.60) beta(0) model(areg quality pc2 teacher_gender teacher_age teacher_experience age study gender, absorb(month))



