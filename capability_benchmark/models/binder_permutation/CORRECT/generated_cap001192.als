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

pred cap001192 { all x, y: CapBenchA | (x->y in capBenchR and (inv11 and ((some CapBenchA and some CapBenchA) or no CapBenchB))) }
pred cap001192c { all a, b: CapBenchA | (b->a in capBenchR and (inv11 and ((some CapBenchA and some CapBenchA) or no CapBenchB))) }
assert CapBenchEquivalent_cap001192 { cap001192 iff cap001192c }
check CapBenchEquivalent_cap001192 for 4
