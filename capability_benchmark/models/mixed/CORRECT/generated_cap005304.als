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

pred cap005304 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv12 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR)) and ((some capBenchS or no CapBenchB) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap005304c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchS or no CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) or (not (inv12 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR)))) }
assert CapBenchEquivalent_cap005304 { cap005304 iff cap005304c }
check CapBenchEquivalent_cap005304 for 4
