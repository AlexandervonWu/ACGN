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

pred cap005205 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv4 and ((some capBenchS or some CapBenchB) or no CapBenchB)) and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some capBenchS))) }
pred cap005205c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some capBenchS)) or (not (inv4 and ((some capBenchS or some CapBenchB) or no CapBenchB)))) }
assert CapBenchEquivalent_cap005205 { cap005205 iff cap005205c }
check CapBenchEquivalent_cap005205 for 4
