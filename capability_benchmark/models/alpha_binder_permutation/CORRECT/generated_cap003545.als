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

pred inv3 {
all c : Course | some teaches.c
}

pred inv3c {
	teaches in Person some -> Course
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap003545 { all x, y: CapBenchA | (x->y in capBenchR and (inv3 and ((some capBenchS or some capBenchS) or some CapBenchA))) }
pred cap003545c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv3 and ((some capBenchS or some capBenchS) or some CapBenchA))) }
assert CapBenchEquivalent_cap003545 { cap003545 iff cap003545c }
check CapBenchEquivalent_cap003545 for 4
