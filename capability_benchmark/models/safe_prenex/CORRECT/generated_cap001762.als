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

pred cap001762 { ((some x: CapBenchA | x->x in capBenchR) and (inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and some capBenchR))) }
pred cap001762c { (some x: CapBenchA | (x->x in capBenchR and (inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and some capBenchR)))) }
assert CapBenchEquivalent_cap001762 { cap001762 iff cap001762c }
check CapBenchEquivalent_cap001762 for 4
