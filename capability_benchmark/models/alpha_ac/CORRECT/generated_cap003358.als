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

pred cap003358 { all x: CapBenchA | (x->x in capBenchR and (inv3 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some capBenchS)) and ((no CapBenchB or no CapBenchA) and some CapBenchA)) }
pred cap003358c { all renamed: CapBenchA | (((no CapBenchB or no CapBenchA) and some CapBenchA) and renamed->renamed in capBenchR and (inv3 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some capBenchS))) }
assert CapBenchEquivalent_cap003358 { cap003358 iff cap003358c }
check CapBenchEquivalent_cap003358 for 4
