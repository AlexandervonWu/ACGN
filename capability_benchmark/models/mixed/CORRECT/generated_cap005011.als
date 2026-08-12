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

pred cap005011 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv8 and ((no CapBenchB or some CapBenchB) and some CapBenchA)) and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or no CapBenchA))) }
pred cap005011c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or no CapBenchA)) or (not (inv8 and ((no CapBenchB or some CapBenchB) and some CapBenchA)))) }
assert CapBenchEquivalent_cap005011 { cap005011 iff cap005011c }
check CapBenchEquivalent_cap005011 for 4
