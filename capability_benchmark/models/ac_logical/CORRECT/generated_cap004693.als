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

pred cap004693 { not ((inv2 and ((some CapBenchB or some CapBenchA) or no CapBenchB)) and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some capBenchS)) }
pred cap004693c { ((not ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some capBenchS)) or (not (inv2 and ((some CapBenchB or some CapBenchA) or no CapBenchB)))) }
assert CapBenchEquivalent_cap004693 { cap004693 iff cap004693c }
check CapBenchEquivalent_cap004693 for 4
