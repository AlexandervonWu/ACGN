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

pred cap001728 { ((some x: CapBenchA | x->x in capBenchR) and (inv11 and ((some capBenchR and some capBenchR) or no CapBenchB))) }
pred cap001728c { (some x: CapBenchA | (x->x in capBenchR and (inv11 and ((some capBenchR and some capBenchR) or no CapBenchB)))) }
assert CapBenchEquivalent_cap001728 { cap001728 iff cap001728c }
check CapBenchEquivalent_cap001728 for 4
