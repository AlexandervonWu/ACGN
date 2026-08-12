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

pred cap004608 { not ((inv1 and ((some capBenchR and some capBenchS) or some CapBenchB)) and ((some CapBenchB or no CapBenchB) or some capBenchR)) }
pred cap004608c { ((not ((some CapBenchB or no CapBenchB) or some capBenchR)) or (not (inv1 and ((some capBenchR and some capBenchS) or some CapBenchB)))) }
assert CapBenchEquivalent_cap004608 { cap004608 iff cap004608c }
check CapBenchEquivalent_cap004608 for 4
