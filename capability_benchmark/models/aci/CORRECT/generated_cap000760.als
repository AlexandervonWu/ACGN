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

pred cap000760 { (inv10 and ((some capBenchR and some CapBenchA) or some capBenchR)) }
pred cap000760c { ((inv10 and ((some capBenchR and some CapBenchA) or some capBenchR)) and (inv10 and ((some capBenchR and some CapBenchA) or some capBenchR))) }
assert CapBenchEquivalent_cap000760 { cap000760 iff cap000760c }
check CapBenchEquivalent_cap000760 for 4
