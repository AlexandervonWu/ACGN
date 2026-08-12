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

pred cap002526 { not historically ((inv2 and ((no CapBenchA and no CapBenchB) and some CapBenchA))) }
pred cap002526c { once (not (inv2 and ((no CapBenchA and no CapBenchB) and some CapBenchA))) }
assert CapBenchEquivalent_cap002526 { cap002526 iff cap002526c }
check CapBenchEquivalent_cap002526 for 4
