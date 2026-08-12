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

pred cap005417 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv2 and ((some CapBenchB or some capBenchR) or capBenchR in (CapBenchA -> CapBenchA))) and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some CapBenchB))) }
pred cap005417c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some CapBenchB)) or (not (inv2 and ((some CapBenchB or some capBenchR) or capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap005417 { cap005417 iff cap005417c }
check CapBenchEquivalent_cap005417 for 4
