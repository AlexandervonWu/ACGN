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

pred cap004879 { not ((inv1 and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some capBenchS)) and ((some CapBenchA and some capBenchS) or some CapBenchA)) }
pred cap004879c { ((not ((some CapBenchA and some capBenchS) or some CapBenchA)) or (not (inv1 and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some capBenchS)))) }
assert CapBenchEquivalent_cap004879 { cap004879 iff cap004879c }
check CapBenchEquivalent_cap004879 for 4
