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

pred cap000507 { ((inv3 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some CapBenchA)) or ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA) or ((no CapBenchA and some capBenchR) and some capBenchS)) }
pred cap000507c { (((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA) or ((no CapBenchA and some capBenchR) and some capBenchS) or (inv3 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some CapBenchA))) }
assert CapBenchEquivalent_cap000507 { cap000507 iff cap000507c }
check CapBenchEquivalent_cap000507 for 4
