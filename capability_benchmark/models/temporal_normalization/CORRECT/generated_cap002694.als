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

pred cap002694 { not historically ((inv1 and ((no CapBenchA and some CapBenchA) and no CapBenchB))) }
pred cap002694c { once (not (inv1 and ((no CapBenchA and some CapBenchA) and no CapBenchB))) }
assert CapBenchEquivalent_cap002694 { cap002694 iff cap002694c }
check CapBenchEquivalent_cap002694 for 4
