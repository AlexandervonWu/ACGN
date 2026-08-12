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

pred cap004739 { not ((inv1 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and no CapBenchB)) and ((some capBenchR and no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap004739c { ((not ((some capBenchR and no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) or (not (inv1 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and no CapBenchB)))) }
assert CapBenchEquivalent_cap004739 { cap004739 iff cap004739c }
check CapBenchEquivalent_cap004739 for 4
