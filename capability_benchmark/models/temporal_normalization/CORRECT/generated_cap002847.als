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

pred cap002847 { not (((inv2 and ((no CapBenchB or no CapBenchB) and some capBenchS))) since (((some CapBenchA and some CapBenchB) or some CapBenchA))) }
pred cap002847c { ((not (inv2 and ((no CapBenchB or no CapBenchB) and some capBenchS))) triggered (not ((some CapBenchA and some CapBenchB) or some CapBenchA))) }
assert CapBenchEquivalent_cap002847 { cap002847 iff cap002847c }
check CapBenchEquivalent_cap002847 for 4
