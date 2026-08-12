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

pred cap004410 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv1 and ((no CapBenchA and no CapBenchB) and capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap004410c { some a, b: CapBenchA | (b->a in capBenchR and (inv1 and ((no CapBenchA and no CapBenchB) and capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap004410 { cap004410 iff cap004410c }
check CapBenchEquivalent_cap004410 for 4
