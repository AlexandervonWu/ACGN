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
all c:Course | c.(~enrolled) in Student
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

pred cap004952 { not ((inv1 and ((some capBenchR and some CapBenchA) or CapBenchA in CapBenchA + CapBenchB)) and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB)) }
pred cap004952c { ((not ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB)) or (not (inv1 and ((some capBenchR and some CapBenchA) or CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap004952 { cap004952 iff cap004952c }
check CapBenchEquivalent_cap004952 for 4
