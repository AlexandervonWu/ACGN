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

pred cap002967 { not (((inv4 and ((no CapBenchB or no CapBenchA) and CapBenchA in CapBenchA + CapBenchB))) since (((some CapBenchA and some CapBenchA) or no CapBenchA))) }
pred cap002967c { ((not (inv4 and ((no CapBenchB or no CapBenchA) and CapBenchA in CapBenchA + CapBenchB))) triggered (not ((some CapBenchA and some CapBenchA) or no CapBenchA))) }
assert CapBenchEquivalent_cap002967 { cap002967 iff cap002967c }
check CapBenchEquivalent_cap002967 for 4
