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
all c:Course | c.(~enrolled) in Student
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

pred cap004332 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv1 and ((some capBenchR and some CapBenchB) or some capBenchS))) }
pred cap004332c { some a, b: CapBenchA | (b->a in capBenchR and (inv1 and ((some capBenchR and some CapBenchB) or some capBenchS))) }
assert CapBenchEquivalent_cap004332 { cap004332 iff cap004332c }
check CapBenchEquivalent_cap004332 for 4
