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

pred cap004502 { not ((inv5 and ((no CapBenchA and some CapBenchA) and some CapBenchA)) and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and no CapBenchA)) }
pred cap004502c { ((not ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and no CapBenchA)) or (not (inv5 and ((no CapBenchA and some CapBenchA) and some CapBenchA)))) }
assert CapBenchEquivalent_cap004502 { cap004502 iff cap004502c }
check CapBenchEquivalent_cap004502 for 4
