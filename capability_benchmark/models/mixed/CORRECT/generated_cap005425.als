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

pred cap005425 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv11 and ((some CapBenchB or some capBenchS) or capBenchR in (CapBenchA -> CapBenchA))) and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some CapBenchB))) }
pred cap005425c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some CapBenchB)) or (not (inv11 and ((some CapBenchB or some capBenchS) or capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap005425 { cap005425 iff cap005425c }
check CapBenchEquivalent_cap005425 for 4
