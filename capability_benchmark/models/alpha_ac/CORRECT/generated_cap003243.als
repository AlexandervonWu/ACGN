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

pred cap003243 { all x: CapBenchA | (x->x in capBenchR and (inv2 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchB)) and ((some CapBenchA and some capBenchR) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap003243c { all renamed: CapBenchA | (((some CapBenchA and some capBenchR) or capBenchR in (CapBenchA -> CapBenchA)) and renamed->renamed in capBenchR and (inv2 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchB))) }
assert CapBenchEquivalent_cap003243 { cap003243 iff cap003243c }
check CapBenchEquivalent_cap003243 for 4
