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
all x: Person - Student | no x.enrolled
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

pred cap000912 { (some (((CapBenchA + CapBenchB) & CapBenchA) & CapBenchA) and (inv1 and ((some capBenchR and no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap000912c { (some ((CapBenchA + CapBenchB) & (CapBenchA & CapBenchA)) and (inv1 and ((some capBenchR and no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap000912 { cap000912 iff cap000912c }
check CapBenchEquivalent_cap000912 for 4
