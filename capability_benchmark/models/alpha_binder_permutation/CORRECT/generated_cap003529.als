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

pred cap003529 { all x, y: CapBenchA | (x->y in capBenchR and (inv12 and ((some capBenchS or no CapBenchB) or some CapBenchA))) }
pred cap003529c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv12 and ((some capBenchS or no CapBenchB) or some CapBenchA))) }
assert CapBenchEquivalent_cap003529 { cap003529 iff cap003529c }
check CapBenchEquivalent_cap003529 for 4
