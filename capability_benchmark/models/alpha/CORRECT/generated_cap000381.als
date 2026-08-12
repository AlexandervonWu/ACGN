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

pred cap000381 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv2 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some capBenchS))) }
pred cap000381c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv2 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some capBenchS))) }
assert CapBenchEquivalent_cap000381 { cap000381 iff cap000381c }
check CapBenchEquivalent_cap000381 for 4
