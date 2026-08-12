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

pred cap002283 { not ((inv11 and ((no CapBenchB or no CapBenchB) and some capBenchR)) and ((some CapBenchA and some CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap002283c { ((not (inv11 and ((no CapBenchB or no CapBenchB) and some capBenchR))) or (not ((some CapBenchA and some CapBenchB) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap002283 { cap002283 iff cap002283c }
check CapBenchEquivalent_cap002283 for 4
