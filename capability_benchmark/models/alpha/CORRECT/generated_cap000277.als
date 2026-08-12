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

pred cap000277 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv11 and ((some capBenchS or no CapBenchA) or some capBenchR))) }
pred cap000277c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv11 and ((some capBenchS or no CapBenchA) or some capBenchR))) }
assert CapBenchEquivalent_cap000277 { cap000277 iff cap000277c }
check CapBenchEquivalent_cap000277 for 4
