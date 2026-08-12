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
enrolled.Course in Student
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

pred cap002441 { ((inv1 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) iff ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some CapBenchB)) }
pred cap002441c { (((not (inv1 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) or ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some CapBenchB)) and ((not ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some CapBenchB)) or (inv1 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap002441 { cap002441 iff cap002441c }
check CapBenchEquivalent_cap002441 for 4
