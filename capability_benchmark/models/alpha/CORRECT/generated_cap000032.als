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

pred cap000032 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv1 and ((some CapBenchA and some capBenchR) or some CapBenchA))) }
pred cap000032c { all alphaOuter: CapBenchA | some alphaInner: CapBenchA | (alphaOuter->alphaInner in capBenchR and (inv1 and ((some CapBenchA and some capBenchR) or some CapBenchA))) }
assert CapBenchEquivalent_cap000032 { cap000032 iff cap000032c }
check CapBenchEquivalent_cap000032 for 4
