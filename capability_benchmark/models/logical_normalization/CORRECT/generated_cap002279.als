open util/ordering[Grade]

sig Person {
	teaches : set Course,
	enrolled : set Course,
	projects : set Project
}

sig Professor,Student in Person {}

sig Course {
	projects : set Project,
	grades : Person -> Grade
}

sig Project {}

sig Grade {}

pred inv10 {
Course.grades.Grade in Student
}

pred inv10c {
	Course.grades.Grade in Student
}

check correct { inv10 <=> inv10c}
pred under { inv10 and !inv10c}
pred over { !inv10 and inv10c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap002279 { ((inv10 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some capBenchR)) iff ((some capBenchR and some CapBenchA) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap002279c { (((not (inv10 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some capBenchR))) or ((some capBenchR and some CapBenchA) or CapBenchA in CapBenchA + CapBenchB)) and ((not ((some capBenchR and some CapBenchA) or CapBenchA in CapBenchA + CapBenchB)) or (inv10 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some capBenchR)))) }
assert CapBenchEquivalent_cap002279 { cap002279 iff cap002279c }
check CapBenchEquivalent_cap002279 for 4
