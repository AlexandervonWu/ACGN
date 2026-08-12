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

pred cap004753 { not ((inv1 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or no CapBenchB)) and ((no CapBenchA and some capBenchS) and capBenchR in (CapBenchA -> CapBenchA))) }
pred cap004753c { ((not ((no CapBenchA and some capBenchS) and capBenchR in (CapBenchA -> CapBenchA))) or (not (inv1 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or no CapBenchB)))) }
assert CapBenchEquivalent_cap004753 { cap004753 iff cap004753c }
check CapBenchEquivalent_cap004753 for 4
