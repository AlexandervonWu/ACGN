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

pred cap000651 { ((inv1 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and no CapBenchA)) or ((some capBenchR and some CapBenchA) or some capBenchS) or ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and CapBenchA in CapBenchA + CapBenchB)) }
pred cap000651c { (((some capBenchR and some CapBenchA) or some capBenchS) or ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and CapBenchA in CapBenchA + CapBenchB) or (inv1 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and no CapBenchA))) }
assert CapBenchEquivalent_cap000651 { cap000651 iff cap000651c }
check CapBenchEquivalent_cap000651 for 4
