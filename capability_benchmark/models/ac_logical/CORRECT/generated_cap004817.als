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

pred cap004817 { not ((inv1 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some capBenchR)) and ((no CapBenchA and some capBenchS) and CapBenchA in CapBenchA + CapBenchB)) }
pred cap004817c { ((not ((no CapBenchA and some capBenchS) and CapBenchA in CapBenchA + CapBenchB)) or (not (inv1 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some capBenchR)))) }
assert CapBenchEquivalent_cap004817 { cap004817 iff cap004817c }
check CapBenchEquivalent_cap004817 for 4
