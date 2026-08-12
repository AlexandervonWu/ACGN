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
all p:Person, c:Course | p in teaches.c implies p in Professor
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

pred cap004140 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv2 and ((some capBenchR and some CapBenchB) or no CapBenchA))) }
pred cap004140c { some a, b: CapBenchA | (b->a in capBenchR and (inv2 and ((some capBenchR and some CapBenchB) or no CapBenchA))) }
assert CapBenchEquivalent_cap004140 { cap004140 iff cap004140c }
check CapBenchEquivalent_cap004140 for 4
