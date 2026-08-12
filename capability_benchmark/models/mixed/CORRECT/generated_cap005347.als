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

pred inv14 {
all p1, p2 : Project, s1, s2 : Person<:projects.p1 | s1 != s2 and p1 != p2 implies s1->p2 not in Person<:projects or s2->p2 not in Person<:projects
}

pred inv14c {
	all p : Person, disj x,y : p.projects | no ((Person <: projects).x & projects.y) - p
}

check correct { inv14 <=> inv14c}
pred under { inv14 and !inv14c}
pred over { !inv14 and inv14c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap005347 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv14 and ((no CapBenchB or no CapBenchB) and some capBenchS)) and ((some CapBenchA and some CapBenchB) or some CapBenchA))) }
pred cap005347c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchA and some CapBenchB) or some CapBenchA)) or (not (inv14 and ((no CapBenchB or no CapBenchB) and some capBenchS)))) }
assert CapBenchEquivalent_cap005347 { cap005347 iff cap005347c }
check CapBenchEquivalent_cap005347 for 4
