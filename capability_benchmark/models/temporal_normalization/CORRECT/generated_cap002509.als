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

pred cap002509 { not once ((inv1 and ((some CapBenchB or some CapBenchB) or some CapBenchA))) }
pred cap002509c { historically (not (inv1 and ((some CapBenchB or some CapBenchB) or some CapBenchA))) }
assert CapBenchEquivalent_cap002509 { cap002509 iff cap002509c }
check CapBenchEquivalent_cap002509 for 4
