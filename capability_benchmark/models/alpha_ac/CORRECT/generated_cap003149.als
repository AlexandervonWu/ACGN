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

pred cap003149 { all x: CapBenchA | (x->x in capBenchR and (inv1 and ((some capBenchS or no CapBenchA) or no CapBenchA)) and ((no CapBenchA and some CapBenchA) and some capBenchS)) }
pred cap003149c { all renamed: CapBenchA | (((no CapBenchA and some CapBenchA) and some capBenchS) and renamed->renamed in capBenchR and (inv1 and ((some capBenchS or no CapBenchA) or no CapBenchA))) }
assert CapBenchEquivalent_cap003149 { cap003149 iff cap003149c }
check CapBenchEquivalent_cap003149 for 4
