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

pred cap001722 { ((some x: CapBenchA | x->x in capBenchR) and (inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and no CapBenchB))) }
pred cap001722c { (some x: CapBenchA | (x->x in capBenchR and (inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and no CapBenchB)))) }
assert CapBenchEquivalent_cap001722 { cap001722 iff cap001722c }
check CapBenchEquivalent_cap001722 for 4
