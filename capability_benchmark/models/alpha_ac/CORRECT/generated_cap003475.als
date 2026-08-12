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

pred cap003475 { all x: CapBenchA | (x->x in capBenchR and (inv1 and ((no CapBenchB or no CapBenchB) and CapBenchA in CapBenchA + CapBenchB)) and ((some CapBenchA and some CapBenchB) or no CapBenchA)) }
pred cap003475c { all renamed: CapBenchA | (((some CapBenchA and some CapBenchB) or no CapBenchA) and renamed->renamed in capBenchR and (inv1 and ((no CapBenchB or no CapBenchB) and CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap003475 { cap003475 iff cap003475c }
check CapBenchEquivalent_cap003475 for 4
