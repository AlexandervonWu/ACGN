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

pred cap003322 { all x: CapBenchA | (x->x in capBenchR and (inv2 and ((no CapBenchA and some CapBenchA) and some capBenchS)) and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and CapBenchA in CapBenchA + CapBenchB)) }
pred cap003322c { all renamed: CapBenchA | (((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and CapBenchA in CapBenchA + CapBenchB) and renamed->renamed in capBenchR and (inv2 and ((no CapBenchA and some CapBenchA) and some capBenchS))) }
assert CapBenchEquivalent_cap003322 { cap003322 iff cap003322c }
check CapBenchEquivalent_cap003322 for 4
