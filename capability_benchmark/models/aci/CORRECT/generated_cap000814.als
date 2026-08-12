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

pred cap000814 { (inv2 and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some capBenchR)) }
pred cap000814c { ((inv2 and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some capBenchR)) and (inv2 and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some capBenchR))) }
assert CapBenchEquivalent_cap000814 { cap000814 iff cap000814c }
check CapBenchEquivalent_cap000814 for 4
