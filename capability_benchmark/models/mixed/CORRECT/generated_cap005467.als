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

pred cap005467 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv2 and ((no CapBenchB or no CapBenchA) and CapBenchA in CapBenchA + CapBenchB)) and ((some CapBenchA and some CapBenchA) or no CapBenchA))) }
pred cap005467c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchA and some CapBenchA) or no CapBenchA)) or (not (inv2 and ((no CapBenchB or no CapBenchA) and CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap005467 { cap005467 iff cap005467c }
check CapBenchEquivalent_cap005467 for 4
