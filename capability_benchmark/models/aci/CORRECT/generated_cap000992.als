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

pred cap000992 { ((inv1 and ((some capBenchR and some capBenchS) or CapBenchA in CapBenchA + CapBenchB)) and ((some CapBenchB or no CapBenchB) or no CapBenchA) and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some capBenchS)) }
pred cap000992c { (((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some capBenchS) and (inv1 and ((some capBenchR and some capBenchS) or CapBenchA in CapBenchA + CapBenchB)) and ((some CapBenchB or no CapBenchB) or no CapBenchA)) }
assert CapBenchEquivalent_cap000992 { cap000992 iff cap000992c }
check CapBenchEquivalent_cap000992 for 4
