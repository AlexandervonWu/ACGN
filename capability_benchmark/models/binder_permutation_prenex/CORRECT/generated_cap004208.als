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

pred cap004208 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv10 and ((some CapBenchA and no CapBenchA) or no CapBenchB))) }
pred cap004208c { some a, b: CapBenchA | (b->a in capBenchR and (inv10 and ((some CapBenchA and no CapBenchA) or no CapBenchB))) }
assert CapBenchEquivalent_cap004208 { cap004208 iff cap004208c }
check CapBenchEquivalent_cap004208 for 4
