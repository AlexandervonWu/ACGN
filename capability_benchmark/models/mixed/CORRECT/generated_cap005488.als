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

pred cap005488 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv1 and ((some CapBenchA and some capBenchS) or CapBenchA in CapBenchA + CapBenchB)) and ((some capBenchS or no CapBenchA) or no CapBenchA))) }
pred cap005488c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchS or no CapBenchA) or no CapBenchA)) or (not (inv1 and ((some CapBenchA and some capBenchS) or CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap005488 { cap005488 iff cap005488c }
check CapBenchEquivalent_cap005488 for 4
