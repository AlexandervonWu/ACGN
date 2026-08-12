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
teaches.Course in Professor
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

pred cap003568 { all x, y: CapBenchA | (x->y in capBenchR and (inv2 and ((some capBenchR and some CapBenchA) or some CapBenchB))) }
pred cap003568c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv2 and ((some capBenchR and some CapBenchA) or some CapBenchB))) }
assert CapBenchEquivalent_cap003568 { cap003568 iff cap003568c }
check CapBenchEquivalent_cap003568 for 4
