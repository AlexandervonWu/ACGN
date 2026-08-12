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

pred cap004654 { not ((inv1 and ((no CapBenchA and no CapBenchB) and no CapBenchA)) and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some capBenchS)) }
pred cap004654c { ((not ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some capBenchS)) or (not (inv1 and ((no CapBenchA and no CapBenchB) and no CapBenchA)))) }
assert CapBenchEquivalent_cap004654 { cap004654 iff cap004654c }
check CapBenchEquivalent_cap004654 for 4
