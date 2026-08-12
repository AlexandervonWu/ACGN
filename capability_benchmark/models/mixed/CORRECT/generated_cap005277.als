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

pred inv5 {
Person.projects - (Person - Student).projects = Project
}

pred inv5c {
	all p : Project | some (Person <: projects).p
	all p : Project | (Person <: projects).p in Student
}

check correct { inv5 <=> inv5c}
pred under { inv5 and !inv5c}
pred over { !inv5 and inv5c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap005277 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv5 and ((some capBenchS or no CapBenchA) or some capBenchR)) and ((no CapBenchA and some CapBenchA) and CapBenchA in CapBenchA + CapBenchB))) }
pred cap005277c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchA and some CapBenchA) and CapBenchA in CapBenchA + CapBenchB)) or (not (inv5 and ((some capBenchS or no CapBenchA) or some capBenchR)))) }
assert CapBenchEquivalent_cap005277 { cap005277 iff cap005277c }
check CapBenchEquivalent_cap005277 for 4
