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

pred cap000723 { ((inv2 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and no CapBenchB)) or ((some capBenchR and some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)) or ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some CapBenchA)) }
pred cap000723c { (((some capBenchR and some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)) or ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some CapBenchA) or (inv2 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and no CapBenchB))) }
assert CapBenchEquivalent_cap000723 { cap000723 iff cap000723c }
check CapBenchEquivalent_cap000723 for 4
