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

pred cap002603 { not eventually ((inv10 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some CapBenchB))) }
pred cap002603c { always (not (inv10 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some CapBenchB))) }
assert CapBenchEquivalent_cap002603 { cap002603 iff cap002603c }
check CapBenchEquivalent_cap002603 for 4
