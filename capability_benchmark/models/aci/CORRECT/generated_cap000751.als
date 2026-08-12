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

pred inv3 {
all c: Course | c in Person.teaches
}

pred inv3c {
	teaches in Person some -> Course
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000751 { (some ((CapBenchA + CapBenchB) + CapBenchA) and (inv3 and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and no CapBenchB))) }
pred cap000751c { (some (CapBenchA + (CapBenchB + CapBenchA)) and (inv3 and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and no CapBenchB))) }
assert CapBenchEquivalent_cap000751 { cap000751 iff cap000751c }
check CapBenchEquivalent_cap000751 for 4
