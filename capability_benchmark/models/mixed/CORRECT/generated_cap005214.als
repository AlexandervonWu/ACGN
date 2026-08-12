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

pred cap005214 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv5 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and no CapBenchB)) and ((no CapBenchB or some CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap005214c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchB or some CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))) or (not (inv5 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and no CapBenchB)))) }
assert CapBenchEquivalent_cap005214 { cap005214 iff cap005214c }
check CapBenchEquivalent_cap005214 for 4
