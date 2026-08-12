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

pred cap005362 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv2 and ((no CapBenchA and some capBenchS) and some capBenchS)) and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some CapBenchA))) }
pred cap005362c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some CapBenchA)) or (not (inv2 and ((no CapBenchA and some capBenchS) and some capBenchS)))) }
assert CapBenchEquivalent_cap005362 { cap005362 iff cap005362c }
check CapBenchEquivalent_cap005362 for 4
