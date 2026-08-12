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

pred cap005176 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv2 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA)) and ((some capBenchS or no CapBenchB) or some capBenchS))) }
pred cap005176c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchS or no CapBenchB) or some capBenchS)) or (not (inv2 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA)))) }
assert CapBenchEquivalent_cap005176 { cap005176 iff cap005176c }
check CapBenchEquivalent_cap005176 for 4
