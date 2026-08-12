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

pred cap000794 { ((inv10 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some capBenchR)) and ((no CapBenchB or no CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and ((some CapBenchB or some CapBenchA) or no CapBenchA)) }
pred cap000794c { (((some CapBenchB or some CapBenchA) or no CapBenchA) and (inv10 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some capBenchR)) and ((no CapBenchB or no CapBenchA) and CapBenchA in CapBenchA + CapBenchB)) }
assert CapBenchEquivalent_cap000794 { cap000794 iff cap000794c }
check CapBenchEquivalent_cap000794 for 4
