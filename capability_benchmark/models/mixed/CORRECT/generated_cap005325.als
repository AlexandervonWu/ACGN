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
enrolled . Course in Student
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

pred cap005325 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv1 and ((some capBenchS or some CapBenchA) or some capBenchS)) and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and CapBenchA in CapBenchA + CapBenchB))) }
pred cap005325c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and CapBenchA in CapBenchA + CapBenchB)) or (not (inv1 and ((some capBenchS or some CapBenchA) or some capBenchS)))) }
assert CapBenchEquivalent_cap005325 { cap005325 iff cap005325c }
check CapBenchEquivalent_cap005325 for 4
