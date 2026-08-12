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

pred cap001794 { ((some x: CapBenchA | x->x in capBenchR) and (inv5 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some capBenchR))) }
pred cap001794c { (some x: CapBenchA | (x->x in capBenchR and (inv5 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some capBenchR)))) }
assert CapBenchEquivalent_cap001794 { cap001794 iff cap001794c }
check CapBenchEquivalent_cap001794 for 4
