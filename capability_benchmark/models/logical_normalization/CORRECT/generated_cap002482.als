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

pred cap002482 { ((inv1 and ((no CapBenchA and some capBenchR) and CapBenchA in CapBenchA + CapBenchB)) implies ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and no CapBenchA)) }
pred cap002482c { ((not (inv1 and ((no CapBenchA and some capBenchR) and CapBenchA in CapBenchA + CapBenchB))) or ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and no CapBenchA)) }
assert CapBenchEquivalent_cap002482 { cap002482 iff cap002482c }
check CapBenchEquivalent_cap002482 for 4
