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

pred cap000857 { (inv1 and ((some capBenchS or some capBenchR) or some capBenchS)) }
pred cap000857c { ((inv1 and ((some capBenchS or some capBenchR) or some capBenchS)) or (inv1 and ((some capBenchS or some capBenchR) or some capBenchS))) }
assert CapBenchEquivalent_cap000857 { cap000857 iff cap000857c }
check CapBenchEquivalent_cap000857 for 4
