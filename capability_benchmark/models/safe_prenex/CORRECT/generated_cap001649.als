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

pred cap001649 { ((all x: CapBenchA | x->x in capBenchR) or (inv1 and ((some capBenchS or no CapBenchA) or no CapBenchA))) }
pred cap001649c { (all x: CapBenchA | (x->x in capBenchR or (inv1 and ((some capBenchS or no CapBenchA) or no CapBenchA)))) }
assert CapBenchEquivalent_cap001649 { cap001649 iff cap001649c }
check CapBenchEquivalent_cap001649 for 4
