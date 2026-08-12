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

pred cap002065 { no x: CapBenchA | (x->x in capBenchR and (inv1 and ((some CapBenchB or some CapBenchA) or some CapBenchB))) }
pred cap002065c { all x: CapBenchA | not (x->x in capBenchR and (inv1 and ((some CapBenchB or some CapBenchA) or some CapBenchB))) }
assert CapBenchEquivalent_cap002065 { cap002065 iff cap002065c }
check CapBenchEquivalent_cap002065 for 4
