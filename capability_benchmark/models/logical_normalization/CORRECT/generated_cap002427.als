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

pred inv3 {
all c : Course | some teaches.c
}

pred inv3c {
	teaches in Person some -> Course
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap002427 { not ((inv3 and ((no CapBenchB or some capBenchS) and capBenchR in (CapBenchA -> CapBenchA))) and ((some CapBenchA and no CapBenchB) or some CapBenchB)) }
pred cap002427c { ((not (inv3 and ((no CapBenchB or some capBenchS) and capBenchR in (CapBenchA -> CapBenchA)))) or (not ((some CapBenchA and no CapBenchB) or some CapBenchB))) }
assert CapBenchEquivalent_cap002427 { cap002427 iff cap002427c }
check CapBenchEquivalent_cap002427 for 4
