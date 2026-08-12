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

pred cap004745 { not ((inv1 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB)) and ((no CapBenchA and some capBenchR) and capBenchR in (CapBenchA -> CapBenchA))) }
pred cap004745c { ((not ((no CapBenchA and some capBenchR) and capBenchR in (CapBenchA -> CapBenchA))) or (not (inv1 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB)))) }
assert CapBenchEquivalent_cap004745 { cap004745 iff cap004745c }
check CapBenchEquivalent_cap004745 for 4
