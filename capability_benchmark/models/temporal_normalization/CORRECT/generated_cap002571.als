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

pred cap002571 { not (((inv5 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some CapBenchB))) since (((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB))) }
pred cap002571c { ((not (inv5 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some CapBenchB))) triggered (not ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB))) }
assert CapBenchEquivalent_cap002571 { cap002571 iff cap002571c }
check CapBenchEquivalent_cap002571 for 4
