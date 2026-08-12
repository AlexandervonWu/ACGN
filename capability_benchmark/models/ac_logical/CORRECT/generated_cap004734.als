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

pred cap004734 { not ((inv2 and ((no CapBenchA and some capBenchS) and no CapBenchB)) and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))) }
pred cap004734c { ((not ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))) or (not (inv2 and ((no CapBenchA and some capBenchS) and no CapBenchB)))) }
assert CapBenchEquivalent_cap004734 { cap004734 iff cap004734c }
check CapBenchEquivalent_cap004734 for 4
