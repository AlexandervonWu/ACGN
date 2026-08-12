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

pred cap001362 { all x, y: CapBenchA | (x->y in capBenchR and (inv2 and ((no CapBenchA and some capBenchS) and some capBenchS))) }
pred cap001362c { all a, b: CapBenchA | (b->a in capBenchR and (inv2 and ((no CapBenchA and some capBenchS) and some capBenchS))) }
assert CapBenchEquivalent_cap001362 { cap001362 iff cap001362c }
check CapBenchEquivalent_cap001362 for 4
