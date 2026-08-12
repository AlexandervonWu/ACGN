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

pred cap003782 { all x, y: CapBenchA | (x->y in capBenchR and (inv2 and ((no CapBenchA and no CapBenchB) and some capBenchR))) }
pred cap003782c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv2 and ((no CapBenchA and no CapBenchB) and some capBenchR))) }
assert CapBenchEquivalent_cap003782 { cap003782 iff cap003782c }
check CapBenchEquivalent_cap003782 for 4
