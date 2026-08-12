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

pred cap003456 { all x: CapBenchA | (x->x in capBenchR and (inv10 and ((some CapBenchA and some CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB)) }
pred cap003456c { all renamed: CapBenchA | (((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB) and renamed->renamed in capBenchR and (inv10 and ((some CapBenchA and some CapBenchB) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap003456 { cap003456 iff cap003456c }
check CapBenchEquivalent_cap003456 for 4
