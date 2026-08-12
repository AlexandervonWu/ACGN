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

pred cap005019 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv4 and ((no CapBenchB or no CapBenchA) and some CapBenchA)) and ((some CapBenchA and some CapBenchA) or no CapBenchB))) }
pred cap005019c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchA and some CapBenchA) or no CapBenchB)) or (not (inv4 and ((no CapBenchB or no CapBenchA) and some CapBenchA)))) }
assert CapBenchEquivalent_cap005019 { cap005019 iff cap005019c }
check CapBenchEquivalent_cap005019 for 4
