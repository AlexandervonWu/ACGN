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

pred cap000732 { (some ((CapBenchA.capBenchR).capBenchR) and (inv1 and ((some CapBenchA and some capBenchS) or no CapBenchB))) }
pred cap000732c { (some (CapBenchA.(capBenchR.capBenchR)) and (inv1 and ((some CapBenchA and some capBenchS) or no CapBenchB))) }
assert CapBenchEquivalent_cap000732 { cap000732 iff cap000732c }
check CapBenchEquivalent_cap000732 for 4
