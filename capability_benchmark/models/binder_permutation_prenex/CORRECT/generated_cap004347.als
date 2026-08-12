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
all p:Person, c:Course, g:Grade | p->g in c.grades implies p in Student
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

pred cap004347 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv10 and ((no CapBenchB or no CapBenchB) and some capBenchS))) }
pred cap004347c { some a, b: CapBenchA | (b->a in capBenchR and (inv10 and ((no CapBenchB or no CapBenchB) and some capBenchS))) }
assert CapBenchEquivalent_cap004347 { cap004347 iff cap004347c }
check CapBenchEquivalent_cap004347 for 4
