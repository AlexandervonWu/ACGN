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

pred cap004596 { not ((inv10 and ((some CapBenchA and some capBenchR) or some CapBenchB)) and ((some capBenchS or some CapBenchB) or some capBenchR)) }
pred cap004596c { ((not ((some capBenchS or some CapBenchB) or some capBenchR)) or (not (inv10 and ((some CapBenchA and some capBenchR) or some CapBenchB)))) }
assert CapBenchEquivalent_cap004596 { cap004596 iff cap004596c }
check CapBenchEquivalent_cap004596 for 4
