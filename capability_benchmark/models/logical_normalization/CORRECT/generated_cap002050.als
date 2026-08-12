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

pred cap002050 { ((inv2 and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchA)) implies ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and no CapBenchB)) }
pred cap002050c { ((not (inv2 and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchA))) or ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and no CapBenchB)) }
assert CapBenchEquivalent_cap002050 { cap002050 iff cap002050c }
check CapBenchEquivalent_cap002050 for 4
