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

pred cap005242 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv3 and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchB)) and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap005242c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))) or (not (inv3 and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchB)))) }
assert CapBenchEquivalent_cap005242 { cap005242 iff cap005242c }
check CapBenchEquivalent_cap005242 for 4
