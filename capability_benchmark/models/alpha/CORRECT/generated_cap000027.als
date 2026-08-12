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

pred cap000027 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv10 and ((no CapBenchB or no CapBenchB) and some CapBenchA))) }
pred cap000027c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv10 and ((no CapBenchB or no CapBenchB) and some CapBenchA))) }
assert CapBenchEquivalent_cap000027 { cap000027 iff cap000027c }
check CapBenchEquivalent_cap000027 for 4
