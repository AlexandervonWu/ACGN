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

pred cap004872 { not ((inv11 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS)) and ((some CapBenchB or some capBenchR) or some CapBenchA)) }
pred cap004872c { ((not ((some CapBenchB or some capBenchR) or some CapBenchA)) or (not (inv11 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS)))) }
assert CapBenchEquivalent_cap004872 { cap004872 iff cap004872c }
check CapBenchEquivalent_cap004872 for 4
