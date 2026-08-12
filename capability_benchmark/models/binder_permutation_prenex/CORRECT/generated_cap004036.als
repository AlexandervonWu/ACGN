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
all p:Person, c:Course | c in p.enrolled implies p in Student
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

pred cap004036 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv1 and ((some capBenchR and some capBenchR) or some CapBenchA))) }
pred cap004036c { some a, b: CapBenchA | (b->a in capBenchR and (inv1 and ((some capBenchR and some capBenchR) or some CapBenchA))) }
assert CapBenchEquivalent_cap004036 { cap004036 iff cap004036c }
check CapBenchEquivalent_cap004036 for 4
