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
enrolled in (Student -> Course)
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

pred cap000622 { (inv1 and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some CapBenchB)) }
pred cap000622c { ((inv1 and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some CapBenchB)) and (inv1 and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some CapBenchB))) }
assert CapBenchEquivalent_cap000622 { cap000622 iff cap000622c }
check CapBenchEquivalent_cap000622 for 4
