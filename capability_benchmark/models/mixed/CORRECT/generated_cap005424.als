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

pred cap005424 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv3 and ((some CapBenchA and some capBenchS) or capBenchR in (CapBenchA -> CapBenchA))) and ((some capBenchS or no CapBenchA) or some CapBenchB))) }
pred cap005424c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchS or no CapBenchA) or some CapBenchB)) or (not (inv3 and ((some CapBenchA and some capBenchS) or capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap005424 { cap005424 iff cap005424c }
check CapBenchEquivalent_cap005424 for 4
