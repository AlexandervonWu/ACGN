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

pred inv4 {
all p:Project | one c:Course | p in c.projects
}

pred inv4c {
	all p : Project | one (Course <: projects).p
}

check correct { inv4 <=> inv4c}
pred under { inv4 and !inv4c}
pred over { !inv4 and inv4c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap003136 { all x: CapBenchA | (x->x in capBenchR and (inv4 and ((some CapBenchA and some CapBenchB) or no CapBenchA)) and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR)) }
pred cap003136c { all renamed: CapBenchA | (((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR) and renamed->renamed in capBenchR and (inv4 and ((some CapBenchA and some CapBenchB) or no CapBenchA))) }
assert CapBenchEquivalent_cap003136 { cap003136 iff cap003136c }
check CapBenchEquivalent_cap003136 for 4
