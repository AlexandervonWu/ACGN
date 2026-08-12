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

pred inv1 {
all p: Person | all c: Course| c in p.enrolled implies p in Student
}

pred inv1c {
	enrolled in Student -> Course
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004076 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv1 and ((some capBenchR and some CapBenchB) or some CapBenchB))) }
pred cap004076c { some a, b: CapBenchA | (b->a in capBenchR and (inv1 and ((some capBenchR and some CapBenchB) or some CapBenchB))) }
assert CapBenchEquivalent_cap004076 { cap004076 iff cap004076c }
check CapBenchEquivalent_cap004076 for 4
