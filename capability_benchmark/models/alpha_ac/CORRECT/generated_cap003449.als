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

pred cap003449 { all x: CapBenchA | (x->x in capBenchR and (inv2 and ((some CapBenchB or some CapBenchA) or CapBenchA in CapBenchA + CapBenchB)) and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some CapBenchB)) }
pred cap003449c { all renamed: CapBenchA | (((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some CapBenchB) and renamed->renamed in capBenchR and (inv2 and ((some CapBenchB or some CapBenchA) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap003449 { cap003449 iff cap003449c }
check CapBenchEquivalent_cap003449 for 4
