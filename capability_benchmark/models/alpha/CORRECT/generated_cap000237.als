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

pred cap000237 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv5 and ((some capBenchS or some capBenchS) or no CapBenchB))) }
pred cap000237c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv5 and ((some capBenchS or some capBenchS) or no CapBenchB))) }
assert CapBenchEquivalent_cap000237 { cap000237 iff cap000237c }
check CapBenchEquivalent_cap000237 for 4
