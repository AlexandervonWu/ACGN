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

pred cap004352 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv3 and ((some CapBenchA and some capBenchR) or some capBenchS))) }
pred cap004352c { some a, b: CapBenchA | (b->a in capBenchR and (inv3 and ((some CapBenchA and some capBenchR) or some capBenchS))) }
assert CapBenchEquivalent_cap004352 { cap004352 iff cap004352c }
check CapBenchEquivalent_cap004352 for 4
