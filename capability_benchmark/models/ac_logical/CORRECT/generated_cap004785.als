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

pred cap004785 { not ((inv11 and ((some capBenchS or no CapBenchB) or some capBenchR)) and ((no CapBenchA and some CapBenchB) and CapBenchA in CapBenchA + CapBenchB)) }
pred cap004785c { ((not ((no CapBenchA and some CapBenchB) and CapBenchA in CapBenchA + CapBenchB)) or (not (inv11 and ((some capBenchS or no CapBenchB) or some capBenchR)))) }
assert CapBenchEquivalent_cap004785 { cap004785 iff cap004785c }
check CapBenchEquivalent_cap004785 for 4
