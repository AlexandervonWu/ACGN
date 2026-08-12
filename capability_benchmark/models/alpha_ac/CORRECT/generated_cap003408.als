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

pred cap003408 { all x: CapBenchA | (x->x in capBenchR and (inv10 and ((some CapBenchA and no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) and ((some capBenchS or some CapBenchA) or some CapBenchB)) }
pred cap003408c { all renamed: CapBenchA | (((some capBenchS or some CapBenchA) or some CapBenchB) and renamed->renamed in capBenchR and (inv10 and ((some CapBenchA and no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap003408 { cap003408 iff cap003408c }
check CapBenchEquivalent_cap003408 for 4
