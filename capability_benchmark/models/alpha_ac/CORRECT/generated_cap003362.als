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

pred cap003362 { all x: CapBenchA | (x->x in capBenchR and (inv4 and ((no CapBenchA and some capBenchS) and some capBenchS)) and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some CapBenchA)) }
pred cap003362c { all renamed: CapBenchA | (((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some CapBenchA) and renamed->renamed in capBenchR and (inv4 and ((no CapBenchA and some capBenchS) and some capBenchS))) }
assert CapBenchEquivalent_cap003362 { cap003362 iff cap003362c }
check CapBenchEquivalent_cap003362 for 4
