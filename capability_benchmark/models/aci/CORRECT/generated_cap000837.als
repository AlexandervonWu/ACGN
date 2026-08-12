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

pred cap000837 { ((inv12 and ((some CapBenchB or no CapBenchA) or some capBenchS)) or ((capBenchR in (CapBenchA -> CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and CapBenchA in CapBenchA + CapBenchB) or ((some capBenchR and some capBenchS) or no CapBenchA)) }
pred cap000837c { (((capBenchR in (CapBenchA -> CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and CapBenchA in CapBenchA + CapBenchB) or ((some capBenchR and some capBenchS) or no CapBenchA) or (inv12 and ((some CapBenchB or no CapBenchA) or some capBenchS))) }
assert CapBenchEquivalent_cap000837 { cap000837 iff cap000837c }
check CapBenchEquivalent_cap000837 for 4
