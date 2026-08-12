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

pred inv10 {
all p:Person, c:Course, g:Grade | p->g in c.grades implies p in Student
}

pred inv10c {
	Course.grades.Grade in Student
}

check correct { inv10 <=> inv10c}
pred under { inv10 and !inv10c}
pred over { !inv10 and inv10c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap002147 { ((inv10 and ((no CapBenchB or no CapBenchA) and no CapBenchA)) iff ((some CapBenchA and some CapBenchA) or some capBenchS)) }
pred cap002147c { (((not (inv10 and ((no CapBenchB or no CapBenchA) and no CapBenchA))) or ((some CapBenchA and some CapBenchA) or some capBenchS)) and ((not ((some CapBenchA and some CapBenchA) or some capBenchS)) or (inv10 and ((no CapBenchB or no CapBenchA) and no CapBenchA)))) }
assert CapBenchEquivalent_cap002147 { cap002147 iff cap002147c }
check CapBenchEquivalent_cap002147 for 4
