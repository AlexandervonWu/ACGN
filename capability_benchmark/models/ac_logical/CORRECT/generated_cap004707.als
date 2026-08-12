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

pred cap004707 { not ((inv10 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and no CapBenchB)) and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some capBenchS)) }
pred cap004707c { ((not ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some capBenchS)) or (not (inv10 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and no CapBenchB)))) }
assert CapBenchEquivalent_cap004707 { cap004707 iff cap004707c }
check CapBenchEquivalent_cap004707 for 4
