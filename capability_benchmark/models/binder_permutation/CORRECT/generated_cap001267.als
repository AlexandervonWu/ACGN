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
all c: Course, p: Person | p in c.~enrolled implies p in Student
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

pred cap001267 { some x, y, z: CapBenchA | (x->y in capBenchR and y->z in capBenchR and (inv1 and ((no CapBenchB or some CapBenchB) and some capBenchR))) }
pred cap001267c { some a, b, c: CapBenchA | (c->b in capBenchR and b->a in capBenchR and (inv1 and ((no CapBenchB or some CapBenchB) and some capBenchR))) }
assert CapBenchEquivalent_cap001267 { cap001267 iff cap001267c }
check CapBenchEquivalent_cap001267 for 4
