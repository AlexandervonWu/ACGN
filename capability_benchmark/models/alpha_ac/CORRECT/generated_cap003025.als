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

pred cap003025 { all x: CapBenchA | (x->x in capBenchR and (inv2 and ((some CapBenchB or no CapBenchB) or some CapBenchA)) and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and no CapBenchB)) }
pred cap003025c { all renamed: CapBenchA | (((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and no CapBenchB) and renamed->renamed in capBenchR and (inv2 and ((some CapBenchB or no CapBenchB) or some CapBenchA))) }
assert CapBenchEquivalent_cap003025 { cap003025 iff cap003025c }
check CapBenchEquivalent_cap003025 for 4
