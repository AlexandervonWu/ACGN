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

pred cap004706 { not ((inv10 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and no CapBenchB)) and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some capBenchS)) }
pred cap004706c { ((not ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some capBenchS)) or (not (inv10 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and no CapBenchB)))) }
assert CapBenchEquivalent_cap004706 { cap004706 iff cap004706c }
check CapBenchEquivalent_cap004706 for 4
