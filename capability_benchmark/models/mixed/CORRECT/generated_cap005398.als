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

pred cap005398 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv5 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))) and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some CapBenchA))) }
pred cap005398c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some CapBenchA)) or (not (inv5 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap005398 { cap005398 iff cap005398c }
check CapBenchEquivalent_cap005398 for 4
