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

pred cap004652 { not ((inv1 and ((some CapBenchA and no CapBenchB) or no CapBenchA)) and ((some capBenchS or some CapBenchA) or some capBenchS)) }
pred cap004652c { ((not ((some capBenchS or some CapBenchA) or some capBenchS)) or (not (inv1 and ((some CapBenchA and no CapBenchB) or no CapBenchA)))) }
assert CapBenchEquivalent_cap004652 { cap004652 iff cap004652c }
check CapBenchEquivalent_cap004652 for 4
