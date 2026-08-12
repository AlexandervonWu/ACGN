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

pred cap001197 { some x, y, z: CapBenchA | (x->y in capBenchR and y->z in capBenchR and (inv2 and ((some capBenchS or some CapBenchA) or no CapBenchB))) }
pred cap001197c { some a, b, c: CapBenchA | (c->b in capBenchR and b->a in capBenchR and (inv2 and ((some capBenchS or some CapBenchA) or no CapBenchB))) }
assert CapBenchEquivalent_cap001197 { cap001197 iff cap001197c }
check CapBenchEquivalent_cap001197 for 4
