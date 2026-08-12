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

pred cap005385 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv2 and ((some CapBenchB or some CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))) and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some CapBenchA))) }
pred cap005385c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some CapBenchA)) or (not (inv2 and ((some CapBenchB or some CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap005385 { cap005385 iff cap005385c }
check CapBenchEquivalent_cap005385 for 4
