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

pred cap002589 { not (((inv2 and ((some CapBenchB or no CapBenchB) or some CapBenchB))) since (((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and some capBenchR))) }
pred cap002589c { ((not (inv2 and ((some CapBenchB or no CapBenchB) or some CapBenchB))) triggered (not ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and some capBenchR))) }
assert CapBenchEquivalent_cap002589 { cap002589 iff cap002589c }
check CapBenchEquivalent_cap002589 for 4
