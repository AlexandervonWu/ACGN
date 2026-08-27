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

pred cap000666 { (some (((CapBenchA + CapBenchB) & CapBenchA) & CapBenchA) and (inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and no CapBenchA))) }
pred cap000666c { (some ((CapBenchA + CapBenchB) & (CapBenchA & CapBenchA)) and (inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and no CapBenchA))) }
assert CapBenchEquivalent_cap000666 { cap000666 iff cap000666c }
check CapBenchEquivalent_cap000666 for 4
