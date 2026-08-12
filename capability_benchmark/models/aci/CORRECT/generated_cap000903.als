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

pred cap000903 { ((inv1 and ((no CapBenchB or no CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))) or ((some CapBenchA and some CapBenchA) or some CapBenchB) or ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and no CapBenchB)) }
pred cap000903c { (((some CapBenchA and some CapBenchA) or some CapBenchB) or ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and no CapBenchB) or (inv1 and ((no CapBenchB or no CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap000903 { cap000903 iff cap000903c }
check CapBenchEquivalent_cap000903 for 4
