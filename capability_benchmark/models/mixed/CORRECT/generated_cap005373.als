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
no (Person-Student) & enrolled.Course
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

pred cap005373 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv1 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS)) and ((no CapBenchA and some capBenchR) and some CapBenchA))) }
pred cap005373c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchA and some capBenchR) and some CapBenchA)) or (not (inv1 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS)))) }
assert CapBenchEquivalent_cap005373 { cap005373 iff cap005373c }
check CapBenchEquivalent_cap005373 for 4
