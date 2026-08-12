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

pred cap003389 { all x: CapBenchA | (x->x in capBenchR and (inv12 and ((some capBenchS or some CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))) and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchA)) }
pred cap003389c { all renamed: CapBenchA | (((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchA) and renamed->renamed in capBenchR and (inv12 and ((some capBenchS or some CapBenchA) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap003389 { cap003389 iff cap003389c }
check CapBenchEquivalent_cap003389 for 4
