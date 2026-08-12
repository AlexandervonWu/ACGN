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
all c:Course | c.(~enrolled) in Student
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

pred cap003517 { all x, y: CapBenchA | (x->y in capBenchR and (inv1 and ((some CapBenchB or no CapBenchA) or some CapBenchA))) }
pred cap003517c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv1 and ((some CapBenchB or no CapBenchA) or some CapBenchA))) }
assert CapBenchEquivalent_cap003517 { cap003517 iff cap003517c }
check CapBenchEquivalent_cap003517 for 4
