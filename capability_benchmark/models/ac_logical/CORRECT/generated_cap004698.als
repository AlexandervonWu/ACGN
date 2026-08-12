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
enrolled . Course in Student
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

pred cap004698 { not ((inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and no CapBenchB)) and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some capBenchS)) }
pred cap004698c { ((not ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some capBenchS)) or (not (inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and no CapBenchB)))) }
assert CapBenchEquivalent_cap004698 { cap004698 iff cap004698c }
check CapBenchEquivalent_cap004698 for 4
