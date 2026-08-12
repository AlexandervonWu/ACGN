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

pred cap005320 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv3 and ((some CapBenchA and some CapBenchA) or some capBenchS)) and ((some capBenchS or some capBenchS) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap005320c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchS or some capBenchS) or CapBenchA in CapBenchA + CapBenchB)) or (not (inv3 and ((some CapBenchA and some CapBenchA) or some capBenchS)))) }
assert CapBenchEquivalent_cap005320 { cap005320 iff cap005320c }
check CapBenchEquivalent_cap005320 for 4
