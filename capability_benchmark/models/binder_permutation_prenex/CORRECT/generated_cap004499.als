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

pred cap004499 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv2 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and CapBenchA in CapBenchA + CapBenchB))) }
pred cap004499c { some a, b: CapBenchA | (b->a in capBenchR and (inv2 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap004499 { cap004499 iff cap004499c }
check CapBenchEquivalent_cap004499 for 4
