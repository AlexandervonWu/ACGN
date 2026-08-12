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

pred cap001338 { all x, y: CapBenchA | (x->y in capBenchR and (inv1 and ((no CapBenchA and no CapBenchA) and some capBenchS))) }
pred cap001338c { all a, b: CapBenchA | (b->a in capBenchR and (inv1 and ((no CapBenchA and no CapBenchA) and some capBenchS))) }
assert CapBenchEquivalent_cap001338 { cap001338 iff cap001338c }
check CapBenchEquivalent_cap001338 for 4
