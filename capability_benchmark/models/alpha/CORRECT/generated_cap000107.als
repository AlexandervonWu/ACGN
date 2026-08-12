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

pred cap000107 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv1 and ((no CapBenchB or some capBenchS) and some CapBenchB))) }
pred cap000107c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv1 and ((no CapBenchB or some capBenchS) and some CapBenchB))) }
assert CapBenchEquivalent_cap000107 { cap000107 iff cap000107c }
check CapBenchEquivalent_cap000107 for 4
