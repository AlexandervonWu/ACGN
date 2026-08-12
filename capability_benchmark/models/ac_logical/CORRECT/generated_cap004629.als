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
no (Person-Student) & enrolled.Course
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

pred cap004629 { not ((inv1 and ((some CapBenchB or some CapBenchA) or no CapBenchA)) and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some capBenchR)) }
pred cap004629c { ((not ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some capBenchR)) or (not (inv1 and ((some CapBenchB or some CapBenchA) or no CapBenchA)))) }
assert CapBenchEquivalent_cap004629 { cap004629 iff cap004629c }
check CapBenchEquivalent_cap004629 for 4
