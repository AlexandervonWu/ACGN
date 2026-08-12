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
all x: Person - Professor | no x.teaches
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

pred cap003670 { all x, y: CapBenchA | (x->y in capBenchR and (inv2 and ((no CapBenchA and some capBenchS) and no CapBenchA))) }
pred cap003670c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv2 and ((no CapBenchA and some capBenchS) and no CapBenchA))) }
assert CapBenchEquivalent_cap003670 { cap003670 iff cap003670c }
check CapBenchEquivalent_cap003670 for 4
