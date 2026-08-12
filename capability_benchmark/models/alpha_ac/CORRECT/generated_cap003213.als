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
enrolled.Course in Student
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

pred cap003213 { all x: CapBenchA | (x->x in capBenchR and (inv1 and ((some capBenchS or no CapBenchA) or no CapBenchB)) and ((no CapBenchA and some CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))) }
pred cap003213c { all renamed: CapBenchA | (((no CapBenchA and some CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and renamed->renamed in capBenchR and (inv1 and ((some capBenchS or no CapBenchA) or no CapBenchB))) }
assert CapBenchEquivalent_cap003213 { cap003213 iff cap003213c }
check CapBenchEquivalent_cap003213 for 4
