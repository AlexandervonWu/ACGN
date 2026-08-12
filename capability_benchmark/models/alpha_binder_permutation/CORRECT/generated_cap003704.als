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

pred cap003704 { all x, y: CapBenchA | (x->y in capBenchR and (inv12 and ((some capBenchR and some CapBenchB) or no CapBenchB))) }
pred cap003704c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv12 and ((some capBenchR and some CapBenchB) or no CapBenchB))) }
assert CapBenchEquivalent_cap003704 { cap003704 iff cap003704c }
check CapBenchEquivalent_cap003704 for 4
