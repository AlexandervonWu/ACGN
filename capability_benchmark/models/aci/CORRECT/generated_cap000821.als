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

pred cap000821 { (inv3 and ((some CapBenchB or some CapBenchA) or some capBenchS)) }
pred cap000821c { ((inv3 and ((some CapBenchB or some CapBenchA) or some capBenchS)) or (inv3 and ((some CapBenchB or some CapBenchA) or some capBenchS))) }
assert CapBenchEquivalent_cap000821 { cap000821 iff cap000821c }
check CapBenchEquivalent_cap000821 for 4
