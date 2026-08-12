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

pred cap002527 { not once ((inv3 and ((no CapBenchB or no CapBenchB) and some CapBenchA))) }
pred cap002527c { historically (not (inv3 and ((no CapBenchB or no CapBenchB) and some CapBenchA))) }
assert CapBenchEquivalent_cap002527 { cap002527 iff cap002527c }
check CapBenchEquivalent_cap002527 for 4
