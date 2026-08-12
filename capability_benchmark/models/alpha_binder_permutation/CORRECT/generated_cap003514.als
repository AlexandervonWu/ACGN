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

pred cap003514 { all x, y: CapBenchA | (x->y in capBenchR and (inv10 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some CapBenchA))) }
pred cap003514c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv10 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some CapBenchA))) }
assert CapBenchEquivalent_cap003514 { cap003514 iff cap003514c }
check CapBenchEquivalent_cap003514 for 4
