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
all p:Person, c:Course | c in p.enrolled implies p in Student
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

pred cap005166 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and no CapBenchA)) and ((no CapBenchB or no CapBenchA) and some capBenchS))) }
pred cap005166c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchB or no CapBenchA) and some capBenchS)) or (not (inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and no CapBenchA)))) }
assert CapBenchEquivalent_cap005166 { cap005166 iff cap005166c }
check CapBenchEquivalent_cap005166 for 4
