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

pred cap003152 { all x: CapBenchA | (x->x in capBenchR and (inv11 and ((some CapBenchA and no CapBenchB) or no CapBenchA)) and ((some capBenchS or some CapBenchA) or some capBenchS)) }
pred cap003152c { all renamed: CapBenchA | (((some capBenchS or some CapBenchA) or some capBenchS) and renamed->renamed in capBenchR and (inv11 and ((some CapBenchA and no CapBenchB) or no CapBenchA))) }
assert CapBenchEquivalent_cap003152 { cap003152 iff cap003152c }
check CapBenchEquivalent_cap003152 for 4
