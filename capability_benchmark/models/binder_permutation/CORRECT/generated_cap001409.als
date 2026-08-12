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

pred cap001409 { some x, y, z: CapBenchA | (x->y in capBenchR and y->z in capBenchR and (inv10 and ((some CapBenchB or no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap001409c { some a, b, c: CapBenchA | (c->b in capBenchR and b->a in capBenchR and (inv10 and ((some CapBenchB or no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap001409 { cap001409 iff cap001409c }
check CapBenchEquivalent_cap001409 for 4
