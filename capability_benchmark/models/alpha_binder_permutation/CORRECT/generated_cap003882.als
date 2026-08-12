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

pred cap003882 { all x, y: CapBenchA | (x->y in capBenchR and (inv8 and ((capBenchR in (CapBenchA -> CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and some capBenchS))) }
pred cap003882c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv8 and ((capBenchR in (CapBenchA -> CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and some capBenchS))) }
assert CapBenchEquivalent_cap003882 { cap003882 iff cap003882c }
check CapBenchEquivalent_cap003882 for 4
