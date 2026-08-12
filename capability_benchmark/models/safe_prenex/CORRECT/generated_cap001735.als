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
no (Person-Student).enrolled
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

pred cap001735 { ((all x: CapBenchA | x->x in capBenchR) or (inv1 and ((no CapBenchB or some capBenchS) and no CapBenchB))) }
pred cap001735c { (all x: CapBenchA | (x->x in capBenchR or (inv1 and ((no CapBenchB or some capBenchS) and no CapBenchB)))) }
assert CapBenchEquivalent_cap001735 { cap001735 iff cap001735c }
check CapBenchEquivalent_cap001735 for 4
