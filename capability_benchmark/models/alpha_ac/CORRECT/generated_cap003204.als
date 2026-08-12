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

pred cap003204 { all x: CapBenchA | (x->x in capBenchR and (inv3 and ((some capBenchR and some CapBenchB) or no CapBenchB)) and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some capBenchS)) }
pred cap003204c { all renamed: CapBenchA | (((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some capBenchS) and renamed->renamed in capBenchR and (inv3 and ((some capBenchR and some CapBenchB) or no CapBenchB))) }
assert CapBenchEquivalent_cap003204 { cap003204 iff cap003204c }
check CapBenchEquivalent_cap003204 for 4
