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

pred cap002713 { not once ((inv2 and ((some capBenchS or no CapBenchA) or no CapBenchB))) }
pred cap002713c { historically (not (inv2 and ((some capBenchS or no CapBenchA) or no CapBenchB))) }
assert CapBenchEquivalent_cap002713 { cap002713 iff cap002713c }
check CapBenchEquivalent_cap002713 for 4
