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

pred cap001719 { ((all x: CapBenchA | x->x in capBenchR) or (inv1 and ((no CapBenchB or no CapBenchB) and no CapBenchB))) }
pred cap001719c { (all x: CapBenchA | (x->x in capBenchR or (inv1 and ((no CapBenchB or no CapBenchB) and no CapBenchB)))) }
assert CapBenchEquivalent_cap001719 { cap001719 iff cap001719c }
check CapBenchEquivalent_cap001719 for 4
