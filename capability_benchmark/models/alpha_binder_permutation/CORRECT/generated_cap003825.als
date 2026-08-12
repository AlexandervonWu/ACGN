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

pred cap003825 { all x, y: CapBenchA | (x->y in capBenchR and (inv8 and ((some capBenchS or some CapBenchA) or some capBenchS))) }
pred cap003825c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv8 and ((some capBenchS or some CapBenchA) or some capBenchS))) }
assert CapBenchEquivalent_cap003825 { cap003825 iff cap003825c }
check CapBenchEquivalent_cap003825 for 4
