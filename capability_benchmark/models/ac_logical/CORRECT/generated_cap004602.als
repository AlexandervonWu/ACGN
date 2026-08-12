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

pred cap004602 { not ((inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some CapBenchB)) and ((no CapBenchB or no CapBenchA) and some capBenchR)) }
pred cap004602c { ((not ((no CapBenchB or no CapBenchA) and some capBenchR)) or (not (inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some CapBenchB)))) }
assert CapBenchEquivalent_cap004602 { cap004602 iff cap004602c }
check CapBenchEquivalent_cap004602 for 4
