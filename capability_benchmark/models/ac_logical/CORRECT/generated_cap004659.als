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
teaches.Course in Professor
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

pred cap004659 { not ((inv2 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and no CapBenchA)) and ((some capBenchR and some CapBenchB) or some capBenchS)) }
pred cap004659c { ((not ((some capBenchR and some CapBenchB) or some capBenchS)) or (not (inv2 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and no CapBenchA)))) }
assert CapBenchEquivalent_cap004659 { cap004659 iff cap004659c }
check CapBenchEquivalent_cap004659 for 4
