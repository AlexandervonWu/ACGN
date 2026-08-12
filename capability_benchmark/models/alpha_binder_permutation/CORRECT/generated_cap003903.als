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

pred cap003903 { all x, y: CapBenchA | (x->y in capBenchR and (inv8 and ((no CapBenchB or no CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap003903c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv8 and ((no CapBenchB or no CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap003903 { cap003903 iff cap003903c }
check CapBenchEquivalent_cap003903 for 4
