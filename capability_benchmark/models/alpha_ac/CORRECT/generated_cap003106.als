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

pred cap003106 { all x: CapBenchA | (x->x in capBenchR and (inv1 and ((no CapBenchA and some capBenchS) and some CapBenchB)) and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some capBenchR)) }
pred cap003106c { all renamed: CapBenchA | (((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some capBenchR) and renamed->renamed in capBenchR and (inv1 and ((no CapBenchA and some capBenchS) and some CapBenchB))) }
assert CapBenchEquivalent_cap003106 { cap003106 iff cap003106c }
check CapBenchEquivalent_cap003106 for 4
