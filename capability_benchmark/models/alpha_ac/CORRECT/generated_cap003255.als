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

pred cap003255 { all x: CapBenchA | (x->x in capBenchR and (inv8 and ((CapBenchA in CapBenchA + CapBenchB or CapBenchA in CapBenchA + CapBenchB) and no CapBenchB)) and ((some capBenchR and some capBenchS) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap003255c { all renamed: CapBenchA | (((some capBenchR and some capBenchS) or capBenchR in (CapBenchA -> CapBenchA)) and renamed->renamed in capBenchR and (inv8 and ((CapBenchA in CapBenchA + CapBenchB or CapBenchA in CapBenchA + CapBenchB) and no CapBenchB))) }
assert CapBenchEquivalent_cap003255 { cap003255 iff cap003255c }
check CapBenchEquivalent_cap003255 for 4
