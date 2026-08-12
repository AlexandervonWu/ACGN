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

pred cap004269 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv4 and ((some capBenchS or some CapBenchB) or some capBenchR))) }
pred cap004269c { some a, b: CapBenchA | (b->a in capBenchR and (inv4 and ((some capBenchS or some CapBenchB) or some capBenchR))) }
assert CapBenchEquivalent_cap004269 { cap004269 iff cap004269c }
check CapBenchEquivalent_cap004269 for 4
