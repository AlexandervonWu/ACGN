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
enrolled in (Student -> Course)
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

pred cap002609 { not eventually ((inv1 and ((some capBenchS or some capBenchS) or some CapBenchB))) }
pred cap002609c { always (not (inv1 and ((some capBenchS or some capBenchS) or some CapBenchB))) }
assert CapBenchEquivalent_cap002609 { cap002609 iff cap002609c }
check CapBenchEquivalent_cap002609 for 4
