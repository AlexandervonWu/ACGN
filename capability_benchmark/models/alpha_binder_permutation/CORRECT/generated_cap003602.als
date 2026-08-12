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

pred inv1 {
enrolled.Course in Student
}

pred inv1c {
	enrolled in Student -> Course
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap003602 { all x, y: CapBenchA | (x->y in capBenchR and (inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some CapBenchB))) }
pred cap003602c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some CapBenchB))) }
assert CapBenchEquivalent_cap003602 { cap003602 iff cap003602c }
check CapBenchEquivalent_cap003602 for 4
