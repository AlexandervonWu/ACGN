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
all p:Person, c:Course | p in teaches.c implies p in Professor
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

pred cap002494 { ((inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and CapBenchA in CapBenchA + CapBenchB)) implies ((no CapBenchB or no CapBenchB) and no CapBenchA)) }
pred cap002494c { ((not (inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and CapBenchA in CapBenchA + CapBenchB))) or ((no CapBenchB or no CapBenchB) and no CapBenchA)) }
assert CapBenchEquivalent_cap002494 { cap002494 iff cap002494c }
check CapBenchEquivalent_cap002494 for 4
