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

pred cap002351 { ((inv2 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some capBenchS)) iff ((some capBenchR and some CapBenchB) or some CapBenchA)) }
pred cap002351c { (((not (inv2 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some capBenchS))) or ((some capBenchR and some CapBenchB) or some CapBenchA)) and ((not ((some capBenchR and some CapBenchB) or some CapBenchA)) or (inv2 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some capBenchS)))) }
assert CapBenchEquivalent_cap002351 { cap002351 iff cap002351c }
check CapBenchEquivalent_cap002351 for 4
