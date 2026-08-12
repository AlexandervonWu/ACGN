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
enrolled . Course in Student
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

pred cap004419 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv1 and ((no CapBenchB or some capBenchR) and capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap004419c { some a, b: CapBenchA | (b->a in capBenchR and (inv1 and ((no CapBenchB or some capBenchR) and capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap004419 { cap004419 iff cap004419c }
check CapBenchEquivalent_cap004419 for 4
