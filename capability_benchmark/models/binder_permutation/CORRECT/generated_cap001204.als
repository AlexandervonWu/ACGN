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

pred cap001204 { all x, y: CapBenchA | (x->y in capBenchR and (inv2 and ((some capBenchR and some CapBenchB) or no CapBenchB))) }
pred cap001204c { all a, b: CapBenchA | (b->a in capBenchR and (inv2 and ((some capBenchR and some CapBenchB) or no CapBenchB))) }
assert CapBenchEquivalent_cap001204 { cap001204 iff cap001204c }
check CapBenchEquivalent_cap001204 for 4
