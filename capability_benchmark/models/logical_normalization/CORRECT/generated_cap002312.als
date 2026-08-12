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

pred cap002312 { not not ((inv1 and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some capBenchR))) }
pred cap002312c { (inv1 and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some capBenchR)) }
assert CapBenchEquivalent_cap002312 { cap002312 iff cap002312c }
check CapBenchEquivalent_cap002312 for 4
