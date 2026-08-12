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
enrolled . Course in Student
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

pred cap000815 { (inv1 and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some capBenchR)) }
pred cap000815c { ((inv1 and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some capBenchR)) or (inv1 and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some capBenchR))) }
assert CapBenchEquivalent_cap000815 { cap000815 iff cap000815c }
check CapBenchEquivalent_cap000815 for 4
