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

pred cap004908 { not ((inv2 and ((some CapBenchA and no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) and ((some capBenchS or some CapBenchA) or some CapBenchB)) }
pred cap004908c { ((not ((some capBenchS or some CapBenchA) or some CapBenchB)) or (not (inv2 and ((some CapBenchA and no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap004908 { cap004908 iff cap004908c }
check CapBenchEquivalent_cap004908 for 4
