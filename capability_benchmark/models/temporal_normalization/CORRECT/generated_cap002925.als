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

pred cap002925 { not (((inv1 and ((some CapBenchB or some capBenchS) or capBenchR in (CapBenchA -> CapBenchA)))) since (((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some CapBenchB))) }
pred cap002925c { ((not (inv1 and ((some CapBenchB or some capBenchS) or capBenchR in (CapBenchA -> CapBenchA)))) triggered (not ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some CapBenchB))) }
assert CapBenchEquivalent_cap002925 { cap002925 iff cap002925c }
check CapBenchEquivalent_cap002925 for 4
