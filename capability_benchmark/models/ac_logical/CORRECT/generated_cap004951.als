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

pred cap004951 { not ((inv2 and ((no CapBenchB or some CapBenchA) and CapBenchA in CapBenchA + CapBenchB)) and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB)) }
pred cap004951c { ((not ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB)) or (not (inv2 and ((no CapBenchB or some CapBenchA) and CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap004951 { cap004951 iff cap004951c }
check CapBenchEquivalent_cap004951 for 4
