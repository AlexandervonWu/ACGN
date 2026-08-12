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

pred cap000163 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv10 and ((no CapBenchB or some capBenchR) and no CapBenchA))) }
pred cap000163c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv10 and ((no CapBenchB or some capBenchR) and no CapBenchA))) }
assert CapBenchEquivalent_cap000163 { cap000163 iff cap000163c }
check CapBenchEquivalent_cap000163 for 4
