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

pred cap002469 { not ((inv2 and ((some capBenchS or no CapBenchA) or CapBenchA in CapBenchA + CapBenchB)) and ((no CapBenchA and some CapBenchA) and no CapBenchA)) }
pred cap002469c { ((not (inv2 and ((some capBenchS or no CapBenchA) or CapBenchA in CapBenchA + CapBenchB))) or (not ((no CapBenchA and some CapBenchA) and no CapBenchA))) }
assert CapBenchEquivalent_cap002469 { cap002469 iff cap002469c }
check CapBenchEquivalent_cap002469 for 4
