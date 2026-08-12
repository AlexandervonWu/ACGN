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

pred inv2 {
all p:Person, c:Course | p in teaches.c implies p in Professor
}

pred inv2c {
	teaches in Professor -> Course
}

check correct { inv2 <=> inv2c}
pred under { inv2 and !inv2c}
pred over { !inv2 and inv2c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap001558 { ((some x: CapBenchA | x->x in capBenchR) and (inv2 and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some CapBenchA))) }
pred cap001558c { (some x: CapBenchA | (x->x in capBenchR and (inv2 and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some CapBenchA)))) }
assert CapBenchEquivalent_cap001558 { cap001558 iff cap001558c }
check CapBenchEquivalent_cap001558 for 4
