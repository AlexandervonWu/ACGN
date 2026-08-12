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

pred cap004647 { not ((inv5 and ((no CapBenchB or no CapBenchA) and no CapBenchA)) and ((some CapBenchA and some CapBenchA) or some capBenchS)) }
pred cap004647c { ((not ((some CapBenchA and some CapBenchA) or some capBenchS)) or (not (inv5 and ((no CapBenchB or no CapBenchA) and no CapBenchA)))) }
assert CapBenchEquivalent_cap004647 { cap004647 iff cap004647c }
check CapBenchEquivalent_cap004647 for 4
