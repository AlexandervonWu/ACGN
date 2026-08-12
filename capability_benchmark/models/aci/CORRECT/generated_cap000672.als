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

pred cap000672 { (some ((CapBenchA.capBenchR).capBenchR) and (inv11 and ((some capBenchR and some capBenchS) or no CapBenchA))) }
pred cap000672c { (some (CapBenchA.(capBenchR.capBenchR)) and (inv11 and ((some capBenchR and some capBenchS) or no CapBenchA))) }
assert CapBenchEquivalent_cap000672 { cap000672 iff cap000672c }
check CapBenchEquivalent_cap000672 for 4
