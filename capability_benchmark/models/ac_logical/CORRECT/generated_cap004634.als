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

pred inv4 {
all p:Project | one c:Course | p in c.projects
}

pred inv4c {
	all p : Project | one (Course <: projects).p
}

check correct { inv4 <=> inv4c}
pred under { inv4 and !inv4c}
pred over { !inv4 and inv4c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004634 { not ((inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and no CapBenchA)) and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some capBenchR)) }
pred cap004634c { ((not ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some capBenchR)) or (not (inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and no CapBenchA)))) }
assert CapBenchEquivalent_cap004634 { cap004634 iff cap004634c }
check CapBenchEquivalent_cap004634 for 4
