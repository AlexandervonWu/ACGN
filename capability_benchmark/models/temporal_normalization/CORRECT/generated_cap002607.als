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

pred cap002607 { not (((inv2 and ((no CapBenchB or some capBenchS) and some CapBenchB))) since (((some CapBenchA and no CapBenchB) or some capBenchR))) }
pred cap002607c { ((not (inv2 and ((no CapBenchB or some capBenchS) and some CapBenchB))) triggered (not ((some CapBenchA and no CapBenchB) or some capBenchR))) }
assert CapBenchEquivalent_cap002607 { cap002607 iff cap002607c }
check CapBenchEquivalent_cap002607 for 4
