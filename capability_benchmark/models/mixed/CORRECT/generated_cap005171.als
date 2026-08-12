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
all p:Person,c:Course | c in p.teaches implies c not in p.enrolled
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

pred cap005171 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv8 and ((no CapBenchB or some capBenchS) and no CapBenchA)) and ((some CapBenchA and no CapBenchB) or some capBenchS))) }
pred cap005171c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchA and no CapBenchB) or some capBenchS)) or (not (inv8 and ((no CapBenchB or some capBenchS) and no CapBenchA)))) }
assert CapBenchEquivalent_cap005171 { cap005171 iff cap005171c }
check CapBenchEquivalent_cap005171 for 4
