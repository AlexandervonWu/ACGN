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

pred cap004297 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv2 and ((some CapBenchB or some capBenchS) or some capBenchR))) }
pred cap004297c { some a, b: CapBenchA | (b->a in capBenchR and (inv2 and ((some CapBenchB or some capBenchS) or some capBenchR))) }
assert CapBenchEquivalent_cap004297 { cap004297 iff cap004297c }
check CapBenchEquivalent_cap004297 for 4
