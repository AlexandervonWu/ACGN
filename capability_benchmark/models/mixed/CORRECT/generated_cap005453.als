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

pred cap005453 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv5 and ((some capBenchS or some CapBenchA) or CapBenchA in CapBenchA + CapBenchB)) and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchB))) }
pred cap005453c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchB)) or (not (inv5 and ((some capBenchS or some CapBenchA) or CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap005453 { cap005453 iff cap005453c }
check CapBenchEquivalent_cap005453 for 4
