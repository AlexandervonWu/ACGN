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
all c: Course, p: Person | p in c.~enrolled implies p in Student
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

pred cap002159 { ((inv1 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and no CapBenchA)) iff ((some capBenchR and some CapBenchB) or some capBenchS)) }
pred cap002159c { (((not (inv1 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and no CapBenchA))) or ((some capBenchR and some CapBenchB) or some capBenchS)) and ((not ((some capBenchR and some CapBenchB) or some capBenchS)) or (inv1 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and no CapBenchA)))) }
assert CapBenchEquivalent_cap002159 { cap002159 iff cap002159c }
check CapBenchEquivalent_cap002159 for 4
