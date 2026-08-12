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

pred cap003365 { all x: CapBenchA | (x->x in capBenchR and (inv8 and ((some capBenchS or some capBenchS) or some capBenchS)) and ((no CapBenchA and no CapBenchB) and some CapBenchA)) }
pred cap003365c { all renamed: CapBenchA | (((no CapBenchA and no CapBenchB) and some CapBenchA) and renamed->renamed in capBenchR and (inv8 and ((some capBenchS or some capBenchS) or some capBenchS))) }
assert CapBenchEquivalent_cap003365 { cap003365 iff cap003365c }
check CapBenchEquivalent_cap003365 for 4
