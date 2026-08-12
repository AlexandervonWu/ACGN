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

pred cap003531 { all x, y: CapBenchA | (x->y in capBenchR and (inv11 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some CapBenchA))) }
pred cap003531c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv11 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some CapBenchA))) }
assert CapBenchEquivalent_cap003531 { cap003531 iff cap003531c }
check CapBenchEquivalent_cap003531 for 4
