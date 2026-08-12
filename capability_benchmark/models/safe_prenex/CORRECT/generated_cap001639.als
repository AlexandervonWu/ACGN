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

pred cap001639 { ((all x: CapBenchA | x->x in capBenchR) or (inv1 and ((no CapBenchB or some CapBenchB) and no CapBenchA))) }
pred cap001639c { (all x: CapBenchA | (x->x in capBenchR or (inv1 and ((no CapBenchB or some CapBenchB) and no CapBenchA)))) }
assert CapBenchEquivalent_cap001639 { cap001639 iff cap001639c }
check CapBenchEquivalent_cap001639 for 4
