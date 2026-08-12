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

pred cap004215 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv1 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and no CapBenchB))) }
pred cap004215c { some a, b: CapBenchA | (b->a in capBenchR and (inv1 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and no CapBenchB))) }
assert CapBenchEquivalent_cap004215 { cap004215 iff cap004215c }
check CapBenchEquivalent_cap004215 for 4
