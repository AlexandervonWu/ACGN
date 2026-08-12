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

pred cap000812 { ((inv1 and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some capBenchR)) and ((some capBenchS or some capBenchR) or CapBenchA in CapBenchA + CapBenchB) and ((no CapBenchB or no CapBenchA) and no CapBenchA)) }
pred cap000812c { (((no CapBenchB or no CapBenchA) and no CapBenchA) and (inv1 and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some capBenchR)) and ((some capBenchS or some capBenchR) or CapBenchA in CapBenchA + CapBenchB)) }
assert CapBenchEquivalent_cap000812 { cap000812 iff cap000812c }
check CapBenchEquivalent_cap000812 for 4
