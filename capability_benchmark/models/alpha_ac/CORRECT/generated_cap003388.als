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

pred cap003388 { all x: CapBenchA | (x->x in capBenchR and (inv1 and ((some capBenchR and some CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))) and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA)) }
pred cap003388c { all renamed: CapBenchA | (((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA) and renamed->renamed in capBenchR and (inv1 and ((some capBenchR and some CapBenchA) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap003388 { cap003388 iff cap003388c }
check CapBenchEquivalent_cap003388 for 4
