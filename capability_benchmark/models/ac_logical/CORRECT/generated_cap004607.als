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

pred cap004607 { not ((inv1 and ((no CapBenchB or some capBenchS) and some CapBenchB)) and ((some CapBenchA and no CapBenchB) or some capBenchR)) }
pred cap004607c { ((not ((some CapBenchA and no CapBenchB) or some capBenchR)) or (not (inv1 and ((no CapBenchB or some capBenchS) and some CapBenchB)))) }
assert CapBenchEquivalent_cap004607 { cap004607 iff cap004607c }
check CapBenchEquivalent_cap004607 for 4
