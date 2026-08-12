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
all c: Course, p: Person | p in c.~enrolled implies p in Student
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

pred cap002534 { not (((inv1 and ((no CapBenchA and some capBenchR) and some CapBenchA))) until (((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and no CapBenchB))) }
pred cap002534c { ((not (inv1 and ((no CapBenchA and some capBenchR) and some CapBenchA))) releases (not ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and no CapBenchB))) }
assert CapBenchEquivalent_cap002534 { cap002534 iff cap002534c }
check CapBenchEquivalent_cap002534 for 4
