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

pred inv8 {
all c: Course, p: Person | c in p.teaches => c not in p.enrolled
}

pred inv8c {
	(all p : Person | no p.teaches & p.enrolled)
}

check correct { inv8 <=> inv8c}
pred under { inv8 and !inv8c}
pred over { !inv8 and inv8c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004131 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv8 and ((no CapBenchB or some CapBenchA) and no CapBenchA))) }
pred cap004131c { some a, b: CapBenchA | (b->a in capBenchR and (inv8 and ((no CapBenchB or some CapBenchA) and no CapBenchA))) }
assert CapBenchEquivalent_cap004131 { cap004131 iff cap004131c }
check CapBenchEquivalent_cap004131 for 4
