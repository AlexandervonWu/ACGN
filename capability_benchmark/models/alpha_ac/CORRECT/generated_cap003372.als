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
all c:Course | c.(~enrolled) in Student
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

pred cap003372 { all x: CapBenchA | (x->x in capBenchR and (inv1 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS)) and ((some CapBenchB or some capBenchR) or some CapBenchA)) }
pred cap003372c { all renamed: CapBenchA | (((some CapBenchB or some capBenchR) or some CapBenchA) and renamed->renamed in capBenchR and (inv1 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS))) }
assert CapBenchEquivalent_cap003372 { cap003372 iff cap003372c }
check CapBenchEquivalent_cap003372 for 4
