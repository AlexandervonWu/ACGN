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

pred cap002207 { ((inv10 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and no CapBenchB)) iff ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some capBenchS)) }
pred cap002207c { (((not (inv10 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and no CapBenchB))) or ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some capBenchS)) and ((not ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some capBenchS)) or (inv10 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and no CapBenchB)))) }
assert CapBenchEquivalent_cap002207 { cap002207 iff cap002207c }
check CapBenchEquivalent_cap002207 for 4
