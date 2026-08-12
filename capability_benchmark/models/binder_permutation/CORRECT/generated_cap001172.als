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

pred cap001172 { all x, y: CapBenchA | (x->y in capBenchR and (inv2 and ((some capBenchR and some capBenchS) or no CapBenchA))) }
pred cap001172c { all a, b: CapBenchA | (b->a in capBenchR and (inv2 and ((some capBenchR and some capBenchS) or no CapBenchA))) }
assert CapBenchEquivalent_cap001172 { cap001172 iff cap001172c }
check CapBenchEquivalent_cap001172 for 4
