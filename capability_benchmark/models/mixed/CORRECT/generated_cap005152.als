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

pred inv1 {
enrolled.Course in Student
}

pred inv1c {
	enrolled in Student -> Course
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap005152 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv1 and ((some CapBenchA and no CapBenchB) or no CapBenchA)) and ((some capBenchS or some CapBenchA) or some capBenchS))) }
pred cap005152c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchS or some CapBenchA) or some capBenchS)) or (not (inv1 and ((some CapBenchA and no CapBenchB) or no CapBenchA)))) }
assert CapBenchEquivalent_cap005152 { cap005152 iff cap005152c }
check CapBenchEquivalent_cap005152 for 4
