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

pred cap004831 { not ((inv1 and ((no CapBenchB or some CapBenchB) and some capBenchS)) and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap004831c { ((not ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) or (not (inv1 and ((no CapBenchB or some CapBenchB) and some capBenchS)))) }
assert CapBenchEquivalent_cap004831 { cap004831 iff cap004831c }
check CapBenchEquivalent_cap004831 for 4
