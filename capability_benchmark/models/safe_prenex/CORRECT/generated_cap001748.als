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

pred cap001748 { ((some x: CapBenchA | x->x in capBenchR) and (inv2 and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or no CapBenchB))) }
pred cap001748c { (some x: CapBenchA | (x->x in capBenchR and (inv2 and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or no CapBenchB)))) }
assert CapBenchEquivalent_cap001748 { cap001748 iff cap001748c }
check CapBenchEquivalent_cap001748 for 4
