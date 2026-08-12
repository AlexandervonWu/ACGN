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

pred cap001531 { ((all x: CapBenchA | x->x in capBenchR) or (inv1 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some CapBenchA))) }
pred cap001531c { (all x: CapBenchA | (x->x in capBenchR or (inv1 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some CapBenchA)))) }
assert CapBenchEquivalent_cap001531 { cap001531 iff cap001531c }
check CapBenchEquivalent_cap001531 for 4
