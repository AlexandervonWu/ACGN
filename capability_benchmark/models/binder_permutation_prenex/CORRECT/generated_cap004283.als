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

pred cap004283 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv1 and ((no CapBenchB or no CapBenchB) and some capBenchR))) }
pred cap004283c { some a, b: CapBenchA | (b->a in capBenchR and (inv1 and ((no CapBenchB or no CapBenchB) and some capBenchR))) }
assert CapBenchEquivalent_cap004283 { cap004283 iff cap004283c }
check CapBenchEquivalent_cap004283 for 4
