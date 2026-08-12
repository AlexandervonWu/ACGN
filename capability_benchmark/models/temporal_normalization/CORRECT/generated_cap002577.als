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

pred cap002577 { not (((inv10 and ((some capBenchS or some CapBenchB) or some CapBenchB))) since (((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and no CapBenchB))) }
pred cap002577c { ((not (inv10 and ((some capBenchS or some CapBenchB) or some CapBenchB))) triggered (not ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and no CapBenchB))) }
assert CapBenchEquivalent_cap002577 { cap002577 iff cap002577c }
check CapBenchEquivalent_cap002577 for 4
