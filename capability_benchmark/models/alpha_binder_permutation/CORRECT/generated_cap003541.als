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

pred cap003541 { all x, y: CapBenchA | (x->y in capBenchR and (inv5 and ((some CapBenchB or some capBenchS) or some CapBenchA))) }
pred cap003541c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv5 and ((some CapBenchB or some capBenchS) or some CapBenchA))) }
assert CapBenchEquivalent_cap003541 { cap003541 iff cap003541c }
check CapBenchEquivalent_cap003541 for 4
