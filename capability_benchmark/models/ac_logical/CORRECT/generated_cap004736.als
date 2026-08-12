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

pred inv1 {
all x: Person - Student | no x.enrolled
}

pred inv1c {
	enrolled in Student -> Course
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004736 { not ((inv1 and ((some capBenchR and some capBenchS) or no CapBenchB)) and ((some CapBenchB or no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap004736c { ((not ((some CapBenchB or no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) or (not (inv1 and ((some capBenchR and some capBenchS) or no CapBenchB)))) }
assert CapBenchEquivalent_cap004736 { cap004736 iff cap004736c }
check CapBenchEquivalent_cap004736 for 4
