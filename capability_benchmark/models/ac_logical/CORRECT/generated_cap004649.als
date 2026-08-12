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

pred cap004649 { not ((inv1 and ((some capBenchS or no CapBenchA) or no CapBenchA)) and ((no CapBenchA and some CapBenchA) and some capBenchS)) }
pred cap004649c { ((not ((no CapBenchA and some CapBenchA) and some capBenchS)) or (not (inv1 and ((some capBenchS or no CapBenchA) or no CapBenchA)))) }
assert CapBenchEquivalent_cap004649 { cap004649 iff cap004649c }
check CapBenchEquivalent_cap004649 for 4
