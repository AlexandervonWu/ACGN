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

pred cap004674 { not ((inv11 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and no CapBenchA)) and ((no CapBenchB or no CapBenchB) and some capBenchS)) }
pred cap004674c { ((not ((no CapBenchB or no CapBenchB) and some capBenchS)) or (not (inv11 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and no CapBenchA)))) }
assert CapBenchEquivalent_cap004674 { cap004674 iff cap004674c }
check CapBenchEquivalent_cap004674 for 4
