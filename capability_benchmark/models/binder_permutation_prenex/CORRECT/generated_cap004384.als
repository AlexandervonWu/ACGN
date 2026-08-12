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

pred cap004384 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv1 and ((some CapBenchA and some CapBenchA) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap004384c { some a, b: CapBenchA | (b->a in capBenchR and (inv1 and ((some CapBenchA and some CapBenchA) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap004384 { cap004384 iff cap004384c }
check CapBenchEquivalent_cap004384 for 4
