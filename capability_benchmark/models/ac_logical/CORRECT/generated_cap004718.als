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

pred cap004718 { not ((inv3 and ((no CapBenchA and no CapBenchB) and no CapBenchB)) and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))) }
pred cap004718c { ((not ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))) or (not (inv3 and ((no CapBenchA and no CapBenchB) and no CapBenchB)))) }
assert CapBenchEquivalent_cap004718 { cap004718 iff cap004718c }
check CapBenchEquivalent_cap004718 for 4
