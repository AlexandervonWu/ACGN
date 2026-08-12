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
no (Person-Student) & enrolled.Course
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

pred cap002759 { not eventually ((inv1 and ((no CapBenchB or some CapBenchA) and some capBenchR))) }
pred cap002759c { always (not (inv1 and ((no CapBenchB or some CapBenchA) and some capBenchR))) }
assert CapBenchEquivalent_cap002759 { cap002759 iff cap002759c }
check CapBenchEquivalent_cap002759 for 4
