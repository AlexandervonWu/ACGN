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

pred cap001342 { all x, y: CapBenchA | (x->y in capBenchR and (inv5 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some capBenchS))) }
pred cap001342c { all a, b: CapBenchA | (b->a in capBenchR and (inv5 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some capBenchS))) }
assert CapBenchEquivalent_cap001342 { cap001342 iff cap001342c }
check CapBenchEquivalent_cap001342 for 4
