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
all x: Person - Student | no x.enrolled
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

pred cap000603 { ((inv1 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some CapBenchB)) or ((some capBenchR and no CapBenchA) or some capBenchR) or ((no CapBenchA and some CapBenchA) and CapBenchA in CapBenchA + CapBenchB)) }
pred cap000603c { (((some capBenchR and no CapBenchA) or some capBenchR) or ((no CapBenchA and some CapBenchA) and CapBenchA in CapBenchA + CapBenchB) or (inv1 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some CapBenchB))) }
assert CapBenchEquivalent_cap000603 { cap000603 iff cap000603c }
check CapBenchEquivalent_cap000603 for 4
