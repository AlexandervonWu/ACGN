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

pred inv12 {
all course:Course | (all p:Person | lone g:Grade | p->g in course.grades)
}

pred inv12c {
	all p : Person, c : Course | lone p.(c.grades)
}

check correct { inv12 <=> inv12c}
pred under { inv12 and !inv12c}
pred over { !inv12 and inv12c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000081 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv12 and ((some CapBenchB or no CapBenchA) or some CapBenchB))) }
pred cap000081c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv12 and ((some CapBenchB or no CapBenchA) or some CapBenchB))) }
assert CapBenchEquivalent_cap000081 { cap000081 iff cap000081c }
check CapBenchEquivalent_cap000081 for 4
