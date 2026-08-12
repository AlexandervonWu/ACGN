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

pred cap000965 { (inv4 and ((some CapBenchB or no CapBenchA) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap000965c { ((inv4 and ((some CapBenchB or no CapBenchA) or CapBenchA in CapBenchA + CapBenchB)) or (inv4 and ((some CapBenchB or no CapBenchA) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap000965 { cap000965 iff cap000965c }
check CapBenchEquivalent_cap000965 for 4
