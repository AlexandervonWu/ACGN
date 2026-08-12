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
all p: Person | all c: Course| c in p.enrolled implies p in Student
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

pred cap004840 { not ((inv1 and ((some capBenchR and no CapBenchA) or some capBenchS)) and ((some CapBenchB or some CapBenchA) or some CapBenchA)) }
pred cap004840c { ((not ((some CapBenchB or some CapBenchA) or some CapBenchA)) or (not (inv1 and ((some capBenchR and no CapBenchA) or some capBenchS)))) }
assert CapBenchEquivalent_cap004840 { cap004840 iff cap004840c }
check CapBenchEquivalent_cap004840 for 4
