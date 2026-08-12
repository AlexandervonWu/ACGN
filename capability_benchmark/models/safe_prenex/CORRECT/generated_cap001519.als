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

pred cap001519 { ((all x: CapBenchA | x->x in capBenchR) or (inv10 and ((no CapBenchB or no CapBenchA) and some CapBenchA))) }
pred cap001519c { (all x: CapBenchA | (x->x in capBenchR or (inv10 and ((no CapBenchB or no CapBenchA) and some CapBenchA)))) }
assert CapBenchEquivalent_cap001519 { cap001519 iff cap001519c }
check CapBenchEquivalent_cap001519 for 4
