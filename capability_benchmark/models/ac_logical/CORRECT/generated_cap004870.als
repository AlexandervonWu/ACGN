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

pred cap004870 { not ((inv1 and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some capBenchS)) and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some CapBenchA)) }
pred cap004870c { ((not ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some CapBenchA)) or (not (inv1 and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some capBenchS)))) }
assert CapBenchEquivalent_cap004870 { cap004870 iff cap004870c }
check CapBenchEquivalent_cap004870 for 4
