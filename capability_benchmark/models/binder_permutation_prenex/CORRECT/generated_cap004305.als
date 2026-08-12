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

pred cap004305 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv1 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR))) }
pred cap004305c { some a, b: CapBenchA | (b->a in capBenchR and (inv1 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR))) }
assert CapBenchEquivalent_cap004305 { cap004305 iff cap004305c }
check CapBenchEquivalent_cap004305 for 4
