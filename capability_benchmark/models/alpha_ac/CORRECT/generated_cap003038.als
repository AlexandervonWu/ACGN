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

pred cap003038 { all x: CapBenchA | (x->x in capBenchR and (inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some CapBenchA)) and ((no CapBenchB or no CapBenchA) and no CapBenchB)) }
pred cap003038c { all renamed: CapBenchA | (((no CapBenchB or no CapBenchA) and no CapBenchB) and renamed->renamed in capBenchR and (inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some CapBenchA))) }
assert CapBenchEquivalent_cap003038 { cap003038 iff cap003038c }
check CapBenchEquivalent_cap003038 for 4
