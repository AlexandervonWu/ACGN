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

pred cap005169 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv11 and ((some CapBenchB or some capBenchS) or no CapBenchA)) and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some capBenchS))) }
pred cap005169c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some capBenchS)) or (not (inv11 and ((some CapBenchB or some capBenchS) or no CapBenchA)))) }
assert CapBenchEquivalent_cap005169 { cap005169 iff cap005169c }
check CapBenchEquivalent_cap005169 for 4
