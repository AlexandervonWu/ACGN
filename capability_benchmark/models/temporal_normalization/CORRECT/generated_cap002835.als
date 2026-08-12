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

pred cap002835 { not (((inv2 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and some capBenchS))) since (((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap002835c { ((not (inv2 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and some capBenchS))) triggered (not ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap002835 { cap002835 iff cap002835c }
check CapBenchEquivalent_cap002835 for 4
