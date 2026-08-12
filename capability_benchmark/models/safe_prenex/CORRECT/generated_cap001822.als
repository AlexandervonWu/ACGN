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

pred cap001822 { ((some x: CapBenchA | x->x in capBenchR) and (inv8 and ((no CapBenchA and some CapBenchA) and some capBenchS))) }
pred cap001822c { (some x: CapBenchA | (x->x in capBenchR and (inv8 and ((no CapBenchA and some CapBenchA) and some capBenchS)))) }
assert CapBenchEquivalent_cap001822 { cap001822 iff cap001822c }
check CapBenchEquivalent_cap001822 for 4
