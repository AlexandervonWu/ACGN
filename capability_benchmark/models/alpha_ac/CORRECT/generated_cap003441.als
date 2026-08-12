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

pred cap003441 { all x: CapBenchA | (x->x in capBenchR and (inv3 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some CapBenchB)) }
pred cap003441c { all renamed: CapBenchA | (((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some CapBenchB) and renamed->renamed in capBenchR and (inv3 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap003441 { cap003441 iff cap003441c }
check CapBenchEquivalent_cap003441 for 4
