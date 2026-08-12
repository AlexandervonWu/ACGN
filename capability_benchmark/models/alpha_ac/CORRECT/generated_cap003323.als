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

pred cap003323 { all x: CapBenchA | (x->x in capBenchR and (inv1 and ((no CapBenchB or some CapBenchA) and some capBenchS)) and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap003323c { all renamed: CapBenchA | (((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or CapBenchA in CapBenchA + CapBenchB) and renamed->renamed in capBenchR and (inv1 and ((no CapBenchB or some CapBenchA) and some capBenchS))) }
assert CapBenchEquivalent_cap003323 { cap003323 iff cap003323c }
check CapBenchEquivalent_cap003323 for 4
