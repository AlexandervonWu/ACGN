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

pred cap002943 { not (((inv3 and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and capBenchR in (CapBenchA -> CapBenchA)))) since (((some CapBenchA and some capBenchS) or some CapBenchB))) }
pred cap002943c { ((not (inv3 and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and capBenchR in (CapBenchA -> CapBenchA)))) triggered (not ((some CapBenchA and some capBenchS) or some CapBenchB))) }
assert CapBenchEquivalent_cap002943 { cap002943 iff cap002943c }
check CapBenchEquivalent_cap002943 for 4
