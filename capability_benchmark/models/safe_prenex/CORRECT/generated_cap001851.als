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

pred cap001851 { ((all x: CapBenchA | x->x in capBenchR) or (inv12 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some capBenchS))) }
pred cap001851c { (all x: CapBenchA | (x->x in capBenchR or (inv12 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some capBenchS)))) }
assert CapBenchEquivalent_cap001851 { cap001851 iff cap001851c }
check CapBenchEquivalent_cap001851 for 4
