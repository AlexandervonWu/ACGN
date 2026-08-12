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

pred cap004536 { not ((inv10 and ((some capBenchR and some capBenchR) or some CapBenchA)) and ((some CapBenchB or no CapBenchA) or no CapBenchB)) }
pred cap004536c { ((not ((some CapBenchB or no CapBenchA) or no CapBenchB)) or (not (inv10 and ((some capBenchR and some capBenchR) or some CapBenchA)))) }
assert CapBenchEquivalent_cap004536 { cap004536 iff cap004536c }
check CapBenchEquivalent_cap004536 for 4
