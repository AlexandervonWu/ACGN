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

pred cap002353 { no x: CapBenchA | (x->x in capBenchR and (inv3 and ((some CapBenchB or some capBenchR) or some capBenchS))) }
pred cap002353c { all x: CapBenchA | not (x->x in capBenchR and (inv3 and ((some CapBenchB or some capBenchR) or some capBenchS))) }
assert CapBenchEquivalent_cap002353 { cap002353 iff cap002353c }
check CapBenchEquivalent_cap002353 for 4
