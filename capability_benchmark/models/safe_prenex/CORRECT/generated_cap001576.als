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

pred cap001576 { ((some x: CapBenchA | x->x in capBenchR) and (inv1 and ((some capBenchR and some CapBenchB) or some CapBenchB))) }
pred cap001576c { (some x: CapBenchA | (x->x in capBenchR and (inv1 and ((some capBenchR and some CapBenchB) or some CapBenchB)))) }
assert CapBenchEquivalent_cap001576 { cap001576 iff cap001576c }
check CapBenchEquivalent_cap001576 for 4
