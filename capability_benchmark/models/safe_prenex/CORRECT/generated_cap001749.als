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

pred cap001749 { ((all x: CapBenchA | x->x in capBenchR) or (inv1 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or no CapBenchB))) }
pred cap001749c { (all x: CapBenchA | (x->x in capBenchR or (inv1 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or no CapBenchB)))) }
assert CapBenchEquivalent_cap001749 { cap001749 iff cap001749c }
check CapBenchEquivalent_cap001749 for 4
