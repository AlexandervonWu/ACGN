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

pred cap002425 { no x: CapBenchA | (x->x in capBenchR and (inv10 and ((some CapBenchB or some capBenchS) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap002425c { all x: CapBenchA | not (x->x in capBenchR and (inv10 and ((some CapBenchB or some capBenchS) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap002425 { cap002425 iff cap002425c }
check CapBenchEquivalent_cap002425 for 4
