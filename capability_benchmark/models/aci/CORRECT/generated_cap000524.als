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

pred cap000524 { ((inv4 and ((some CapBenchA and no CapBenchB) or some CapBenchA)) and ((some capBenchS or some CapBenchA) or no CapBenchB) and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some capBenchS)) }
pred cap000524c { (((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some capBenchS) and (inv4 and ((some CapBenchA and no CapBenchB) or some CapBenchA)) and ((some capBenchS or some CapBenchA) or no CapBenchB)) }
assert CapBenchEquivalent_cap000524 { cap000524 iff cap000524c }
check CapBenchEquivalent_cap000524 for 4
