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
enrolled in (Student -> Course)
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

pred cap001568 { ((some x: CapBenchA | x->x in capBenchR) and (inv1 and ((some capBenchR and some CapBenchA) or some CapBenchB))) }
pred cap001568c { (some x: CapBenchA | (x->x in capBenchR and (inv1 and ((some capBenchR and some CapBenchA) or some CapBenchB)))) }
assert CapBenchEquivalent_cap001568 { cap001568 iff cap001568c }
check CapBenchEquivalent_cap001568 for 4
