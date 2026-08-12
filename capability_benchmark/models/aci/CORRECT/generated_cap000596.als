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
enrolled.Course in Student
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

pred cap000596 { ((inv1 and ((some CapBenchA and some capBenchR) or some CapBenchB)) and ((some capBenchS or some CapBenchB) or some capBenchR) and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))) }
pred cap000596c { (((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and capBenchR in (CapBenchA -> CapBenchA)) and (inv1 and ((some CapBenchA and some capBenchR) or some CapBenchB)) and ((some capBenchS or some CapBenchB) or some capBenchR)) }
assert CapBenchEquivalent_cap000596 { cap000596 iff cap000596c }
check CapBenchEquivalent_cap000596 for 4
