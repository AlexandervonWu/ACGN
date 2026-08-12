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

pred cap003462 { all x: CapBenchA | (x->x in capBenchR and (inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and CapBenchA in CapBenchA + CapBenchB)) and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some CapBenchB)) }
pred cap003462c { all renamed: CapBenchA | (((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some CapBenchB) and renamed->renamed in capBenchR and (inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap003462 { cap003462 iff cap003462c }
check CapBenchEquivalent_cap003462 for 4
