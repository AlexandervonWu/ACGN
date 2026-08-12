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
all x: Person - Student | no x.enrolled
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

pred cap003664 { all x, y: CapBenchA | (x->y in capBenchR and (inv1 and ((some capBenchR and some capBenchR) or no CapBenchA))) }
pred cap003664c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv1 and ((some capBenchR and some capBenchR) or no CapBenchA))) }
assert CapBenchEquivalent_cap003664 { cap003664 iff cap003664c }
check CapBenchEquivalent_cap003664 for 4
