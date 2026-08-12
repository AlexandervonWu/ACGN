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

pred cap001599 { ((all x: CapBenchA | x->x in capBenchR) or (inv1 and ((no CapBenchB or some capBenchR) and some CapBenchB))) }
pred cap001599c { (all x: CapBenchA | (x->x in capBenchR or (inv1 and ((no CapBenchB or some capBenchR) and some CapBenchB)))) }
assert CapBenchEquivalent_cap001599 { cap001599 iff cap001599c }
check CapBenchEquivalent_cap001599 for 4
