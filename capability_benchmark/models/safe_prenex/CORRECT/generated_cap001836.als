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

pred cap001836 { ((some x: CapBenchA | x->x in capBenchR) and (inv8 and ((some CapBenchA and no CapBenchA) or some capBenchS))) }
pred cap001836c { (some x: CapBenchA | (x->x in capBenchR and (inv8 and ((some CapBenchA and no CapBenchA) or some capBenchS)))) }
assert CapBenchEquivalent_cap001836 { cap001836 iff cap001836c }
check CapBenchEquivalent_cap001836 for 4
