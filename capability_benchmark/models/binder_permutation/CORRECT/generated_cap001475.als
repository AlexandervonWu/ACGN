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

pred cap001475 { some x, y, z: CapBenchA | (x->y in capBenchR and y->z in capBenchR and (inv11 and ((no CapBenchB or no CapBenchB) and CapBenchA in CapBenchA + CapBenchB))) }
pred cap001475c { some a, b, c: CapBenchA | (c->b in capBenchR and b->a in capBenchR and (inv11 and ((no CapBenchB or no CapBenchB) and CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap001475 { cap001475 iff cap001475c }
check CapBenchEquivalent_cap001475 for 4
