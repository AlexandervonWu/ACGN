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

pred cap003353 { all x: CapBenchA | (x->x in capBenchR and (inv8 and ((some CapBenchB or some capBenchR) or some capBenchS)) and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some CapBenchA)) }
pred cap003353c { all renamed: CapBenchA | (((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some CapBenchA) and renamed->renamed in capBenchR and (inv8 and ((some CapBenchB or some capBenchR) or some capBenchS))) }
assert CapBenchEquivalent_cap003353 { cap003353 iff cap003353c }
check CapBenchEquivalent_cap003353 for 4
