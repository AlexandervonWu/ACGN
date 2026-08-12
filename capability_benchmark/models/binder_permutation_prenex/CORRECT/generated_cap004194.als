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

pred cap004194 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv1 and ((no CapBenchA and some CapBenchA) and no CapBenchB))) }
pred cap004194c { some a, b: CapBenchA | (b->a in capBenchR and (inv1 and ((no CapBenchA and some CapBenchA) and no CapBenchB))) }
assert CapBenchEquivalent_cap004194 { cap004194 iff cap004194c }
check CapBenchEquivalent_cap004194 for 4
