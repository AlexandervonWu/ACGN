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
all p: Person | all c: Course| c in p.enrolled implies p in Student
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

pred cap003096 { all x: CapBenchA | (x->x in capBenchR and (inv1 and ((some CapBenchA and some capBenchR) or some CapBenchB)) and ((some capBenchS or some CapBenchB) or some capBenchR)) }
pred cap003096c { all renamed: CapBenchA | (((some capBenchS or some CapBenchB) or some capBenchR) and renamed->renamed in capBenchR and (inv1 and ((some CapBenchA and some capBenchR) or some CapBenchB))) }
assert CapBenchEquivalent_cap003096 { cap003096 iff cap003096c }
check CapBenchEquivalent_cap003096 for 4
