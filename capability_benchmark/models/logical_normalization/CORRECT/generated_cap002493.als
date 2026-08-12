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

pred inv12 {
all course:Course | (all p:Person | lone g:Grade | p->g in course.grades)
}

pred inv12c {
	all p : Person, c : Course | lone p.(c.grades)
}

check correct { inv12 <=> inv12c}
pred under { inv12 and !inv12c}
pred over { !inv12 and inv12c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap002493 { not ((inv12 and ((some capBenchS or some capBenchS) or CapBenchA in CapBenchA + CapBenchB)) and ((no CapBenchA and no CapBenchB) and no CapBenchA)) }
pred cap002493c { ((not (inv12 and ((some capBenchS or some capBenchS) or CapBenchA in CapBenchA + CapBenchB))) or (not ((no CapBenchA and no CapBenchB) and no CapBenchA))) }
assert CapBenchEquivalent_cap002493 { cap002493 iff cap002493c }
check CapBenchEquivalent_cap002493 for 4
