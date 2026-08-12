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
all p:Person,c:Course | c in p.teaches implies c not in p.enrolled
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

pred cap004233 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv8 and ((some CapBenchB or some capBenchS) or no CapBenchB))) }
pred cap004233c { some a, b: CapBenchA | (b->a in capBenchR and (inv8 and ((some CapBenchB or some capBenchS) or no CapBenchB))) }
assert CapBenchEquivalent_cap004233 { cap004233 iff cap004233c }
check CapBenchEquivalent_cap004233 for 4
