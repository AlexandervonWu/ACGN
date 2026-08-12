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

pred cap003139 { all x: CapBenchA | (x->x in capBenchR and (inv10 and ((no CapBenchB or some CapBenchB) and no CapBenchA)) and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some capBenchR)) }
pred cap003139c { all renamed: CapBenchA | (((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some capBenchR) and renamed->renamed in capBenchR and (inv10 and ((no CapBenchB or some CapBenchB) and no CapBenchA))) }
assert CapBenchEquivalent_cap003139 { cap003139 iff cap003139c }
check CapBenchEquivalent_cap003139 for 4
