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

pred inv2 {
all x: Person - Professor | no x.teaches
}

pred inv2c {
	teaches in Professor -> Course
}

check correct { inv2 <=> inv2c}
pred under { inv2 and !inv2c}
pred over { !inv2 and inv2c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004543 { not ((inv2 and ((no CapBenchB or some capBenchS) and some CapBenchA)) and ((some CapBenchA and no CapBenchB) or no CapBenchB)) }
pred cap004543c { ((not ((some CapBenchA and no CapBenchB) or no CapBenchB)) or (not (inv2 and ((no CapBenchB or some capBenchS) and some CapBenchA)))) }
assert CapBenchEquivalent_cap004543 { cap004543 iff cap004543c }
check CapBenchEquivalent_cap004543 for 4
