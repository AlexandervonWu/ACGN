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

pred cap001600 { ((some x: CapBenchA | x->x in capBenchR) and (inv14 and ((some capBenchR and some capBenchR) or some CapBenchB))) }
pred cap001600c { (some x: CapBenchA | (x->x in capBenchR and (inv14 and ((some capBenchR and some capBenchR) or some CapBenchB)))) }
assert CapBenchEquivalent_cap001600 { cap001600 iff cap001600c }
check CapBenchEquivalent_cap001600 for 4
