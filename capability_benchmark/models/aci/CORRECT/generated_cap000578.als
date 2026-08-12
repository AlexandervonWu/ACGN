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

pred cap000578 { ((inv8 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some CapBenchB)) and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and no CapBenchB) and ((some CapBenchB or some capBenchS) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap000578c { (((some CapBenchB or some capBenchS) or capBenchR in (CapBenchA -> CapBenchA)) and (inv8 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some CapBenchB)) and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and no CapBenchB)) }
assert CapBenchEquivalent_cap000578 { cap000578 iff cap000578c }
check CapBenchEquivalent_cap000578 for 4
