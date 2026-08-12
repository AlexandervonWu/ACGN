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

pred cap001178 { all x, y: CapBenchA | (x->y in capBenchR and (inv2 and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchA))) }
pred cap001178c { all a, b: CapBenchA | (b->a in capBenchR and (inv2 and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchA))) }
assert CapBenchEquivalent_cap001178 { cap001178 iff cap001178c }
check CapBenchEquivalent_cap001178 for 4
