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

pred inv11 {
all c : Course | c.grades.Grade in (c.~enrolled)
}

pred inv11c {
	all c : Course | c.grades.Grade in enrolled.c
}

check correct { inv11 <=> inv11c}
pred under { inv11 and !inv11c}
pred over { !inv11 and inv11c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap002960 { not (((inv11 and ((some capBenchR and some CapBenchB) or CapBenchA in CapBenchA + CapBenchB))) until (((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some CapBenchB))) }
pred cap002960c { ((not (inv11 and ((some capBenchR and some CapBenchB) or CapBenchA in CapBenchA + CapBenchB))) releases (not ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some CapBenchB))) }
assert CapBenchEquivalent_cap002960 { cap002960 iff cap002960c }
check CapBenchEquivalent_cap002960 for 4
