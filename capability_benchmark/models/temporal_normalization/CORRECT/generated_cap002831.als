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
(all p1: Project | some pr1: Student | pr1->p1 in projects)
	(all p2: Project | all pr2: Person | pr2->p2 in projects implies pr2 in Student)
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

pred cap002831 { not eventually ((inv5 and ((no CapBenchB or some CapBenchB) and some capBenchS))) }
pred cap002831c { always (not (inv5 and ((no CapBenchB or some CapBenchB) and some capBenchS))) }
assert CapBenchEquivalent_cap002831 { cap002831 iff cap002831c }
check CapBenchEquivalent_cap002831 for 4
