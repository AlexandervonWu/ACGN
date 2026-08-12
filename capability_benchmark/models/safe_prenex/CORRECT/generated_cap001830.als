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

pred cap001830 { ((some x: CapBenchA | x->x in capBenchR) and (inv1 and ((no CapBenchA and some CapBenchB) and some capBenchS))) }
pred cap001830c { (some x: CapBenchA | (x->x in capBenchR and (inv1 and ((no CapBenchA and some CapBenchB) and some capBenchS)))) }
assert CapBenchEquivalent_cap001830 { cap001830 iff cap001830c }
check CapBenchEquivalent_cap001830 for 4
