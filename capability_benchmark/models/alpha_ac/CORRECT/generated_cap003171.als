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

pred cap003171 { all x: CapBenchA | (x->x in capBenchR and (inv2 and ((no CapBenchB or some capBenchS) and no CapBenchA)) and ((some CapBenchA and no CapBenchB) or some capBenchS)) }
pred cap003171c { all renamed: CapBenchA | (((some CapBenchA and no CapBenchB) or some capBenchS) and renamed->renamed in capBenchR and (inv2 and ((no CapBenchB or some capBenchS) and no CapBenchA))) }
assert CapBenchEquivalent_cap003171 { cap003171 iff cap003171c }
check CapBenchEquivalent_cap003171 for 4
