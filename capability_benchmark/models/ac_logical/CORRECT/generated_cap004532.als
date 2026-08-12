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

pred cap004532 { not ((inv1 and ((some CapBenchA and some capBenchR) or some CapBenchA)) and ((some capBenchS or some CapBenchB) or no CapBenchB)) }
pred cap004532c { ((not ((some capBenchS or some CapBenchB) or no CapBenchB)) or (not (inv1 and ((some CapBenchA and some capBenchR) or some CapBenchA)))) }
assert CapBenchEquivalent_cap004532 { cap004532 iff cap004532c }
check CapBenchEquivalent_cap004532 for 4
