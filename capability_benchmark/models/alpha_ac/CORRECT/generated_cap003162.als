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
all p:Person, c:Course | c in p.enrolled implies p in Student
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

pred cap003162 { all x: CapBenchA | (x->x in capBenchR and (inv1 and ((no CapBenchA and some capBenchR) and no CapBenchA)) and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and some capBenchS)) }
pred cap003162c { all renamed: CapBenchA | (((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and some capBenchS) and renamed->renamed in capBenchR and (inv1 and ((no CapBenchA and some capBenchR) and no CapBenchA))) }
assert CapBenchEquivalent_cap003162 { cap003162 iff cap003162c }
check CapBenchEquivalent_cap003162 for 4
