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

pred cap003450 { all x: CapBenchA | (x->x in capBenchR and (inv5 and ((no CapBenchA and some CapBenchA) and CapBenchA in CapBenchA + CapBenchB)) and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some CapBenchB)) }
pred cap003450c { all renamed: CapBenchA | (((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some CapBenchB) and renamed->renamed in capBenchR and (inv5 and ((no CapBenchA and some CapBenchA) and CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap003450 { cap003450 iff cap003450c }
check CapBenchEquivalent_cap003450 for 4
