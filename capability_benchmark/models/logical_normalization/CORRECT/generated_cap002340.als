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

pred cap002340 { not (all x: CapBenchA | (x->x in capBenchR and (inv1 and ((some capBenchR and no CapBenchA) or some capBenchS)))) }
pred cap002340c { some x: CapBenchA | not (x->x in capBenchR and (inv1 and ((some capBenchR and no CapBenchA) or some capBenchS))) }
assert CapBenchEquivalent_cap002340 { cap002340 iff cap002340c }
check CapBenchEquivalent_cap002340 for 4
