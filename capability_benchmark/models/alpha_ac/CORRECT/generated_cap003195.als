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

pred cap003195 { all x: CapBenchA | (x->x in capBenchR and (inv2 and ((no CapBenchB or some CapBenchA) and no CapBenchB)) and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS)) }
pred cap003195c { all renamed: CapBenchA | (((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS) and renamed->renamed in capBenchR and (inv2 and ((no CapBenchB or some CapBenchA) and no CapBenchB))) }
assert CapBenchEquivalent_cap003195 { cap003195 iff cap003195c }
check CapBenchEquivalent_cap003195 for 4
