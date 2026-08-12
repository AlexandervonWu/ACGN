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
no (Person-Student) & enrolled.Course
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

pred cap002323 { no x: CapBenchA | (x->x in capBenchR and (inv1 and ((no CapBenchB or some CapBenchA) and some capBenchS))) }
pred cap002323c { all x: CapBenchA | not (x->x in capBenchR and (inv1 and ((no CapBenchB or some CapBenchA) and some capBenchS))) }
assert CapBenchEquivalent_cap002323 { cap002323 iff cap002323c }
check CapBenchEquivalent_cap002323 for 4
