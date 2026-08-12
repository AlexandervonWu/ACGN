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

pred cap001023 { some x, y, z: CapBenchA | (x->y in capBenchR and y->z in capBenchR and (inv1 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some CapBenchA))) }
pred cap001023c { some a, b, c: CapBenchA | (c->b in capBenchR and b->a in capBenchR and (inv1 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some CapBenchA))) }
assert CapBenchEquivalent_cap001023 { cap001023 iff cap001023c }
check CapBenchEquivalent_cap001023 for 4
