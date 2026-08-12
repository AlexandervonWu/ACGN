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

pred cap005397 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv2 and ((some capBenchS or some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some CapBenchA))) }
pred cap005397c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some CapBenchA)) or (not (inv2 and ((some capBenchS or some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap005397 { cap005397 iff cap005397c }
check CapBenchEquivalent_cap005397 for 4
