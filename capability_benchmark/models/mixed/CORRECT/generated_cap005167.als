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

pred cap005167 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv3 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and no CapBenchA)) and ((some capBenchR and no CapBenchA) or some capBenchS))) }
pred cap005167c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchR and no CapBenchA) or some capBenchS)) or (not (inv3 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and no CapBenchA)))) }
assert CapBenchEquivalent_cap005167 { cap005167 iff cap005167c }
check CapBenchEquivalent_cap005167 for 4
