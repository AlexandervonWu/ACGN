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

pred cap002288 { not not ((inv5 and ((some CapBenchA and some capBenchR) or some capBenchR))) }
pred cap002288c { (inv5 and ((some CapBenchA and some capBenchR) or some capBenchR)) }
assert CapBenchEquivalent_cap002288 { cap002288 iff cap002288c }
check CapBenchEquivalent_cap002288 for 4
