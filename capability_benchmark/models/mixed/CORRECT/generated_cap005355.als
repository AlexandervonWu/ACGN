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
all c: Course, p: Person | p in c.~enrolled implies p in Student
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

pred cap005355 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv1 and ((no CapBenchB or some capBenchR) and some capBenchS)) and ((some CapBenchA and no CapBenchA) or some CapBenchA))) }
pred cap005355c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchA and no CapBenchA) or some CapBenchA)) or (not (inv1 and ((no CapBenchB or some capBenchR) and some capBenchS)))) }
assert CapBenchEquivalent_cap005355 { cap005355 iff cap005355c }
check CapBenchEquivalent_cap005355 for 4
