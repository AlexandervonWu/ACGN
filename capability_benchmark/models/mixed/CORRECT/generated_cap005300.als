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

pred cap005300 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv1 and ((some capBenchR and some capBenchS) or some capBenchR)) and ((some CapBenchB or no CapBenchB) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap005300c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchB or no CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) or (not (inv1 and ((some capBenchR and some capBenchS) or some capBenchR)))) }
assert CapBenchEquivalent_cap005300 { cap005300 iff cap005300c }
check CapBenchEquivalent_cap005300 for 4
