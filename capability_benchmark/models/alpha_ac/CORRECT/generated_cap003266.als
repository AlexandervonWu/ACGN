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
enrolled . Course in Student
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

pred cap003266 { all x: CapBenchA | (x->x in capBenchR and (inv1 and ((no CapBenchA and some CapBenchB) and some capBenchR)) and ((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and capBenchR in (CapBenchA -> CapBenchA))) }
pred cap003266c { all renamed: CapBenchA | (((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and capBenchR in (CapBenchA -> CapBenchA)) and renamed->renamed in capBenchR and (inv1 and ((no CapBenchA and some CapBenchB) and some capBenchR))) }
assert CapBenchEquivalent_cap003266 { cap003266 iff cap003266c }
check CapBenchEquivalent_cap003266 for 4
