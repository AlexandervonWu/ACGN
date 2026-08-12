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

pred cap005108 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv5 and ((some capBenchR and some capBenchS) or some CapBenchB)) and ((some CapBenchB or no CapBenchB) or some capBenchR))) }
pred cap005108c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchB or no CapBenchB) or some capBenchR)) or (not (inv5 and ((some capBenchR and some capBenchS) or some CapBenchB)))) }
assert CapBenchEquivalent_cap005108 { cap005108 iff cap005108c }
check CapBenchEquivalent_cap005108 for 4
