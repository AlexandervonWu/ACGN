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
all c:Course | c.(~enrolled) in Student
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

pred cap001879 { ((all x: CapBenchA | x->x in capBenchR) or (inv1 and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some capBenchS))) }
pred cap001879c { (all x: CapBenchA | (x->x in capBenchR or (inv1 and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some capBenchS)))) }
assert CapBenchEquivalent_cap001879 { cap001879 iff cap001879c }
check CapBenchEquivalent_cap001879 for 4
