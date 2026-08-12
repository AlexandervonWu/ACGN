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

pred cap005219 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv2 and ((no CapBenchB or no CapBenchB) and no CapBenchB)) and ((some CapBenchA and some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap005219c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchA and some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) or (not (inv2 and ((no CapBenchB or no CapBenchB) and no CapBenchB)))) }
assert CapBenchEquivalent_cap005219 { cap005219 iff cap005219c }
check CapBenchEquivalent_cap005219 for 4
