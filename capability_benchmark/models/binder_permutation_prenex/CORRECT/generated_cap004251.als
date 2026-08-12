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

pred cap004251 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv10 and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and no CapBenchB))) }
pred cap004251c { some a, b: CapBenchA | (b->a in capBenchR and (inv10 and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and no CapBenchB))) }
assert CapBenchEquivalent_cap004251 { cap004251 iff cap004251c }
check CapBenchEquivalent_cap004251 for 4
