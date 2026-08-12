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

pred inv11 {
all c : Course | c.grades.Grade in (c.~enrolled)
}

pred inv11c {
	all c : Course | c.grades.Grade in enrolled.c
}

check correct { inv11 <=> inv11c}
pred under { inv11 and !inv11c}
pred over { !inv11 and inv11c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap005092 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv11 and ((some capBenchR and no CapBenchB) or some CapBenchB)) and ((some CapBenchB or some CapBenchB) or some capBenchR))) }
pred cap005092c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchB or some CapBenchB) or some capBenchR)) or (not (inv11 and ((some capBenchR and no CapBenchB) or some CapBenchB)))) }
assert CapBenchEquivalent_cap005092 { cap005092 iff cap005092c }
check CapBenchEquivalent_cap005092 for 4
