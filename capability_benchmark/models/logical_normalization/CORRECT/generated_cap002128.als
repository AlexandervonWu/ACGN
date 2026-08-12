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

pred cap002128 { ((inv14 and ((some CapBenchA and some CapBenchA) or no CapBenchA)) implies ((some capBenchS or some capBenchS) or some capBenchR)) }
pred cap002128c { ((not (inv14 and ((some CapBenchA and some CapBenchA) or no CapBenchA))) or ((some capBenchS or some capBenchS) or some capBenchR)) }
assert CapBenchEquivalent_cap002128 { cap002128 iff cap002128c }
check CapBenchEquivalent_cap002128 for 4
