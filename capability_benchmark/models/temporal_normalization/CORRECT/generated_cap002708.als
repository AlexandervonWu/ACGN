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

pred cap002708 { not (((inv1 and ((some CapBenchA and no CapBenchA) or no CapBenchB))) until (((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some capBenchS))) }
pred cap002708c { ((not (inv1 and ((some CapBenchA and no CapBenchA) or no CapBenchB))) releases (not ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some capBenchS))) }
assert CapBenchEquivalent_cap002708 { cap002708 iff cap002708c }
check CapBenchEquivalent_cap002708 for 4
