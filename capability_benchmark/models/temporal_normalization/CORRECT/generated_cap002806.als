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

pred cap002806 { not always ((inv11 and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some capBenchR))) }
pred cap002806c { eventually (not (inv11 and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some capBenchR))) }
assert CapBenchEquivalent_cap002806 { cap002806 iff cap002806c }
check CapBenchEquivalent_cap002806 for 4
