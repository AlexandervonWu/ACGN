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

pred cap005240 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv14 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB)) and ((some capBenchS or no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap005240c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchS or no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) or (not (inv14 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB)))) }
assert CapBenchEquivalent_cap005240 { cap005240 iff cap005240c }
check CapBenchEquivalent_cap005240 for 4
