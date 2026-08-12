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

pred cap002094 { not (all x: CapBenchA | (x->x in capBenchR and (inv3 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some CapBenchB)))) }
pred cap002094c { some x: CapBenchA | not (x->x in capBenchR and (inv3 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some CapBenchB))) }
assert CapBenchEquivalent_cap002094 { cap002094 iff cap002094c }
check CapBenchEquivalent_cap002094 for 4
