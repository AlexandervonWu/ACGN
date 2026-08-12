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

pred cap004576 { not ((inv8 and ((some capBenchR and some CapBenchB) or some CapBenchB)) and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or no CapBenchB)) }
pred cap004576c { ((not ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or no CapBenchB)) or (not (inv8 and ((some capBenchR and some CapBenchB) or some CapBenchB)))) }
assert CapBenchEquivalent_cap004576 { cap004576 iff cap004576c }
check CapBenchEquivalent_cap004576 for 4
