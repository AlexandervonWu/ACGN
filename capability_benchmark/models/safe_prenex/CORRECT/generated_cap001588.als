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

pred cap001588 { ((some x: CapBenchA | x->x in capBenchR) and (inv10 and ((some CapBenchA and no CapBenchB) or some CapBenchB))) }
pred cap001588c { (some x: CapBenchA | (x->x in capBenchR and (inv10 and ((some CapBenchA and no CapBenchB) or some CapBenchB)))) }
assert CapBenchEquivalent_cap001588 { cap001588 iff cap001588c }
check CapBenchEquivalent_cap001588 for 4
