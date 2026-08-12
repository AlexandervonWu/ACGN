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
no (Person-Student) & enrolled.Course
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

pred cap003091 { all x: CapBenchA | (x->x in capBenchR and (inv1 and ((no CapBenchB or no CapBenchB) and some CapBenchB)) and ((some CapBenchA and some CapBenchB) or some capBenchR)) }
pred cap003091c { all renamed: CapBenchA | (((some CapBenchA and some CapBenchB) or some capBenchR) and renamed->renamed in capBenchR and (inv1 and ((no CapBenchB or no CapBenchB) and some CapBenchB))) }
assert CapBenchEquivalent_cap003091 { cap003091 iff cap003091c }
check CapBenchEquivalent_cap003091 for 4
