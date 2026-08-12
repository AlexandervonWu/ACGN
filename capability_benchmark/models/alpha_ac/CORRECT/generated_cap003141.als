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

pred cap003141 { all x: CapBenchA | (x->x in capBenchR and (inv2 and ((some capBenchS or some CapBenchB) or no CapBenchA)) and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some capBenchR)) }
pred cap003141c { all renamed: CapBenchA | (((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some capBenchR) and renamed->renamed in capBenchR and (inv2 and ((some capBenchS or some CapBenchB) or no CapBenchA))) }
assert CapBenchEquivalent_cap003141 { cap003141 iff cap003141c }
check CapBenchEquivalent_cap003141 for 4
