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

pred cap004168 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv2 and ((some CapBenchA and some capBenchS) or no CapBenchA))) }
pred cap004168c { some a, b: CapBenchA | (b->a in capBenchR and (inv2 and ((some CapBenchA and some capBenchS) or no CapBenchA))) }
assert CapBenchEquivalent_cap004168 { cap004168 iff cap004168c }
check CapBenchEquivalent_cap004168 for 4
