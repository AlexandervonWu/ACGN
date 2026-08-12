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

pred cap003366 { all x: CapBenchA | (x->x in capBenchR and (inv11 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some capBenchS)) and ((no CapBenchB or no CapBenchB) and some CapBenchA)) }
pred cap003366c { all renamed: CapBenchA | (((no CapBenchB or no CapBenchB) and some CapBenchA) and renamed->renamed in capBenchR and (inv11 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some capBenchS))) }
assert CapBenchEquivalent_cap003366 { cap003366 iff cap003366c }
check CapBenchEquivalent_cap003366 for 4
