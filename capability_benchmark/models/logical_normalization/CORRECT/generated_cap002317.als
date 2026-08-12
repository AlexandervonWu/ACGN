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

pred cap002317 { no x: CapBenchA | (x->x in capBenchR and (inv1 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some capBenchR))) }
pred cap002317c { all x: CapBenchA | not (x->x in capBenchR and (inv1 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some capBenchR))) }
assert CapBenchEquivalent_cap002317 { cap002317 iff cap002317c }
check CapBenchEquivalent_cap002317 for 4
