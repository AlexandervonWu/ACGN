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

pred cap003166 { all x: CapBenchA | (x->x in capBenchR and (inv14 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and no CapBenchA)) and ((no CapBenchB or no CapBenchA) and some capBenchS)) }
pred cap003166c { all renamed: CapBenchA | (((no CapBenchB or no CapBenchA) and some capBenchS) and renamed->renamed in capBenchR and (inv14 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and no CapBenchA))) }
assert CapBenchEquivalent_cap003166 { cap003166 iff cap003166c }
check CapBenchEquivalent_cap003166 for 4
