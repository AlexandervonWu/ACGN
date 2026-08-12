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

pred cap004841 { not ((inv1 and ((some capBenchS or no CapBenchA) or some capBenchS)) and ((no CapBenchA and some CapBenchA) and some CapBenchA)) }
pred cap004841c { ((not ((no CapBenchA and some CapBenchA) and some CapBenchA)) or (not (inv1 and ((some capBenchS or no CapBenchA) or some capBenchS)))) }
assert CapBenchEquivalent_cap004841 { cap004841 iff cap004841c }
check CapBenchEquivalent_cap004841 for 4
