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

pred cap002104 { ((inv4 and ((some CapBenchA and some capBenchS) or some CapBenchB)) implies ((some capBenchS or no CapBenchA) or some capBenchR)) }
pred cap002104c { ((not (inv4 and ((some CapBenchA and some capBenchS) or some CapBenchB))) or ((some capBenchS or no CapBenchA) or some capBenchR)) }
assert CapBenchEquivalent_cap002104 { cap002104 iff cap002104c }
check CapBenchEquivalent_cap002104 for 4
