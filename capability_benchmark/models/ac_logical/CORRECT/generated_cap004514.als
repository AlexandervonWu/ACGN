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

pred cap004514 { not ((inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some CapBenchA)) and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and no CapBenchA)) }
pred cap004514c { ((not ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and no CapBenchA)) or (not (inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some CapBenchA)))) }
assert CapBenchEquivalent_cap004514 { cap004514 iff cap004514c }
check CapBenchEquivalent_cap004514 for 4
