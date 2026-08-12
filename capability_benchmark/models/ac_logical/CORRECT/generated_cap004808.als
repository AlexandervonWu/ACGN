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

pred cap004808 { not ((inv2 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR)) and ((some CapBenchB or some capBenchR) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap004808c { ((not ((some CapBenchB or some capBenchR) or CapBenchA in CapBenchA + CapBenchB)) or (not (inv2 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR)))) }
assert CapBenchEquivalent_cap004808 { cap004808 iff cap004808c }
check CapBenchEquivalent_cap004808 for 4
