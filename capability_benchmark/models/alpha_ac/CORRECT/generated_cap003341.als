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

pred cap003341 { all x: CapBenchA | (x->x in capBenchR and (inv3 and ((some capBenchS or no CapBenchA) or some capBenchS)) and ((no CapBenchA and some CapBenchA) and some CapBenchA)) }
pred cap003341c { all renamed: CapBenchA | (((no CapBenchA and some CapBenchA) and some CapBenchA) and renamed->renamed in capBenchR and (inv3 and ((some capBenchS or no CapBenchA) or some capBenchS))) }
assert CapBenchEquivalent_cap003341 { cap003341 iff cap003341c }
check CapBenchEquivalent_cap003341 for 4
