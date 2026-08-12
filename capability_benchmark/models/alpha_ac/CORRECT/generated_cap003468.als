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

pred cap003468 { all x: CapBenchA | (x->x in capBenchR and (inv1 and ((some capBenchR and no CapBenchA) or CapBenchA in CapBenchA + CapBenchB)) and ((some CapBenchB or some CapBenchA) or no CapBenchA)) }
pred cap003468c { all renamed: CapBenchA | (((some CapBenchB or some CapBenchA) or no CapBenchA) and renamed->renamed in capBenchR and (inv1 and ((some capBenchR and no CapBenchA) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap003468 { cap003468 iff cap003468c }
check CapBenchEquivalent_cap003468 for 4
