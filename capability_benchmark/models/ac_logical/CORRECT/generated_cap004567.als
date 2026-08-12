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

pred cap004567 { not ((inv10 and ((no CapBenchB or some CapBenchA) and some CapBenchB)) and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB)) }
pred cap004567c { ((not ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB)) or (not (inv10 and ((no CapBenchB or some CapBenchA) and some CapBenchB)))) }
assert CapBenchEquivalent_cap004567 { cap004567 iff cap004567c }
check CapBenchEquivalent_cap004567 for 4
