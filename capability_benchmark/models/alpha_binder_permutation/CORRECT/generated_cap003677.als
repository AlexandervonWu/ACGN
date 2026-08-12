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

pred cap003677 { all x, y: CapBenchA | (x->y in capBenchR and (inv8 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA))) }
pred cap003677c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv8 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA))) }
assert CapBenchEquivalent_cap003677 { cap003677 iff cap003677c }
check CapBenchEquivalent_cap003677 for 4
