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

pred cap002231 { ((inv1 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and no CapBenchB)) iff ((some capBenchR and no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap002231c { (((not (inv1 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and no CapBenchB))) or ((some capBenchR and no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))) and ((not ((some capBenchR and no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))) or (inv1 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and no CapBenchB)))) }
assert CapBenchEquivalent_cap002231 { cap002231 iff cap002231c }
check CapBenchEquivalent_cap002231 for 4
