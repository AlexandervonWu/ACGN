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

pred cap000182 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv12 and ((capBenchR in (CapBenchA -> CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchA))) }
pred cap000182c { all alphaOuter: CapBenchA | some alphaInner: CapBenchA | (alphaOuter->alphaInner in capBenchR and (inv12 and ((capBenchR in (CapBenchA -> CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchA))) }
assert CapBenchEquivalent_cap000182 { cap000182 iff cap000182c }
check CapBenchEquivalent_cap000182 for 4
