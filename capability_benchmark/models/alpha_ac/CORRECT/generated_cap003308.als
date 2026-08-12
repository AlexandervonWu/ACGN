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
Course.grades.Grade in Student
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

pred cap003308 { all x: CapBenchA | (x->x in capBenchR and (inv10 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR)) and ((some CapBenchB or some capBenchR) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap003308c { all renamed: CapBenchA | (((some CapBenchB or some capBenchR) or CapBenchA in CapBenchA + CapBenchB) and renamed->renamed in capBenchR and (inv10 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR))) }
assert CapBenchEquivalent_cap003308 { cap003308 iff cap003308c }
check CapBenchEquivalent_cap003308 for 4
