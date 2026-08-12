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
no (Person-Student).enrolled
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

pred cap002987 { not eventually ((inv1 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and CapBenchA in CapBenchA + CapBenchB))) }
pred cap002987c { always (not (inv1 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap002987 { cap002987 iff cap002987c }
check CapBenchEquivalent_cap002987 for 4
