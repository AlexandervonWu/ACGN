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

pred cap002663 { not eventually ((inv12 and ((no CapBenchB or some capBenchR) and no CapBenchA))) }
pred cap002663c { always (not (inv12 and ((no CapBenchB or some capBenchR) and no CapBenchA))) }
assert CapBenchEquivalent_cap002663 { cap002663 iff cap002663c }
check CapBenchEquivalent_cap002663 for 4
