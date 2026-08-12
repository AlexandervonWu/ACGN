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

pred cap001636 { ((some x: CapBenchA | x->x in capBenchR) and (inv1 and ((some CapBenchA and some CapBenchB) or no CapBenchA))) }
pred cap001636c { (some x: CapBenchA | (x->x in capBenchR and (inv1 and ((some CapBenchA and some CapBenchB) or no CapBenchA)))) }
assert CapBenchEquivalent_cap001636 { cap001636 iff cap001636c }
check CapBenchEquivalent_cap001636 for 4
