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

pred cap002651 { not eventually ((inv11 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and no CapBenchA))) }
pred cap002651c { always (not (inv11 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and no CapBenchA))) }
assert CapBenchEquivalent_cap002651 { cap002651 iff cap002651c }
check CapBenchEquivalent_cap002651 for 4
