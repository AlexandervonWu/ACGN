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

pred inv8 {
all c: Course, p: Person | c in p.teaches => c not in p.enrolled
}

pred inv8c {
	(all p : Person | no p.teaches & p.enrolled)
}

check correct { inv8 <=> inv8c}
pred under { inv8 and !inv8c}
pred over { !inv8 and inv8c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap005149 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv8 and ((some capBenchS or no CapBenchA) or no CapBenchA)) and ((no CapBenchA and some CapBenchA) and some capBenchS))) }
pred cap005149c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchA and some CapBenchA) and some capBenchS)) or (not (inv8 and ((some capBenchS or no CapBenchA) or no CapBenchA)))) }
assert CapBenchEquivalent_cap005149 { cap005149 iff cap005149c }
check CapBenchEquivalent_cap005149 for 4
