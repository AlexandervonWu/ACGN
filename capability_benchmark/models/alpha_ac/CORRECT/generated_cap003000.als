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

pred cap003000 { all x: CapBenchA | (x->x in capBenchR and (inv1 and ((some CapBenchA and some CapBenchA) or some CapBenchA)) and ((some capBenchS or some capBenchS) or no CapBenchA)) }
pred cap003000c { all renamed: CapBenchA | (((some capBenchS or some capBenchS) or no CapBenchA) and renamed->renamed in capBenchR and (inv1 and ((some CapBenchA and some CapBenchA) or some CapBenchA))) }
assert CapBenchEquivalent_cap003000 { cap003000 iff cap003000c }
check CapBenchEquivalent_cap003000 for 4
