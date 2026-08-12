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

pred cap002988 { not historically ((inv8 and ((some CapBenchA and some capBenchS) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap002988c { once (not (inv8 and ((some CapBenchA and some capBenchS) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap002988 { cap002988 iff cap002988c }
check CapBenchEquivalent_cap002988 for 4
