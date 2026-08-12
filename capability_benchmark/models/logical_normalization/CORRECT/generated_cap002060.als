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

pred cap002060 { not not ((inv12 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some CapBenchA))) }
pred cap002060c { (inv12 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some CapBenchA)) }
assert CapBenchEquivalent_cap002060 { cap002060 iff cap002060c }
check CapBenchEquivalent_cap002060 for 4
