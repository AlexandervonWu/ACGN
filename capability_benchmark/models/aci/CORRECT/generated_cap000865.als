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

pred cap000865 { (some ((CapBenchA + CapBenchB) + CapBenchA) and (inv1 and ((some capBenchS or some capBenchS) or some capBenchS))) }
pred cap000865c { (some (CapBenchA + (CapBenchB + CapBenchA)) and (inv1 and ((some capBenchS or some capBenchS) or some capBenchS))) }
assert CapBenchEquivalent_cap000865 { cap000865 iff cap000865c }
check CapBenchEquivalent_cap000865 for 4
