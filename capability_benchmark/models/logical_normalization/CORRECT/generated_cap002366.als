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

pred cap002366 { not not ((inv5 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some capBenchS))) }
pred cap002366c { (inv5 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some capBenchS)) }
assert CapBenchEquivalent_cap002366 { cap002366 iff cap002366c }
check CapBenchEquivalent_cap002366 for 4
