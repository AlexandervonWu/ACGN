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

pred cap003724 { all x, y: CapBenchA | (x->y in capBenchR and (inv4 and ((some CapBenchA and some capBenchR) or no CapBenchB))) }
pred cap003724c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv4 and ((some CapBenchA and some capBenchR) or no CapBenchB))) }
assert CapBenchEquivalent_cap003724 { cap003724 iff cap003724c }
check CapBenchEquivalent_cap003724 for 4
