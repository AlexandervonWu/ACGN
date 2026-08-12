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

pred cap005174 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv12 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and no CapBenchA)) and ((no CapBenchB or no CapBenchB) and some capBenchS))) }
pred cap005174c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchB or no CapBenchB) and some capBenchS)) or (not (inv12 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and no CapBenchA)))) }
assert CapBenchEquivalent_cap005174 { cap005174 iff cap005174c }
check CapBenchEquivalent_cap005174 for 4
