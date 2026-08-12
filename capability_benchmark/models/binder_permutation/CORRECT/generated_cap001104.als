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

pred cap001104 { all x, y: CapBenchA | (x->y in capBenchR and (inv1 and ((some CapBenchA and some capBenchS) or some CapBenchB))) }
pred cap001104c { all a, b: CapBenchA | (b->a in capBenchR and (inv1 and ((some CapBenchA and some capBenchS) or some CapBenchB))) }
assert CapBenchEquivalent_cap001104 { cap001104 iff cap001104c }
check CapBenchEquivalent_cap001104 for 4
