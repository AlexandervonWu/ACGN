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
all p: Person | all c: Course| c in p.enrolled implies p in Student
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

pred cap005032 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv1 and ((some CapBenchA and some capBenchR) or some CapBenchA)) and ((some capBenchS or some CapBenchB) or no CapBenchB))) }
pred cap005032c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchS or some CapBenchB) or no CapBenchB)) or (not (inv1 and ((some CapBenchA and some capBenchR) or some CapBenchA)))) }
assert CapBenchEquivalent_cap005032 { cap005032 iff cap005032c }
check CapBenchEquivalent_cap005032 for 4
