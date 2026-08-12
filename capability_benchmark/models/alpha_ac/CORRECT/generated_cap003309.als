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

pred cap003309 { all x: CapBenchA | (x->x in capBenchR and (inv11 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR)) and ((no CapBenchA and some capBenchR) and CapBenchA in CapBenchA + CapBenchB)) }
pred cap003309c { all renamed: CapBenchA | (((no CapBenchA and some capBenchR) and CapBenchA in CapBenchA + CapBenchB) and renamed->renamed in capBenchR and (inv11 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR))) }
assert CapBenchEquivalent_cap003309 { cap003309 iff cap003309c }
check CapBenchEquivalent_cap003309 for 4
