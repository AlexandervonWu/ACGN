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

pred cap002076 { not (all x: CapBenchA | (x->x in capBenchR and (inv10 and ((some capBenchR and some CapBenchB) or some CapBenchB)))) }
pred cap002076c { some x: CapBenchA | not (x->x in capBenchR and (inv10 and ((some capBenchR and some CapBenchB) or some CapBenchB))) }
assert CapBenchEquivalent_cap002076 { cap002076 iff cap002076c }
check CapBenchEquivalent_cap002076 for 4
