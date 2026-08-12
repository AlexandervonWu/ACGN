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

pred inv2 {
all x: Person - Professor | no x.teaches
}

pred inv2c {
	teaches in Professor -> Course
}

check correct { inv2 <=> inv2c}
pred under { inv2 and !inv2c}
pred over { !inv2 and inv2c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004279 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv2 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some capBenchR))) }
pred cap004279c { some a, b: CapBenchA | (b->a in capBenchR and (inv2 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some capBenchR))) }
assert CapBenchEquivalent_cap004279 { cap004279 iff cap004279c }
check CapBenchEquivalent_cap004279 for 4
