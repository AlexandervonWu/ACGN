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

pred inv3 {
all c: Course | c in Person.teaches
}

pred inv3c {
	teaches in Person some -> Course
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap003490 { all x: CapBenchA | (x->x in capBenchR and (inv3 and ((no CapBenchA and some capBenchS) and CapBenchA in CapBenchA + CapBenchB)) and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and no CapBenchA)) }
pred cap003490c { all renamed: CapBenchA | (((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and no CapBenchA) and renamed->renamed in capBenchR and (inv3 and ((no CapBenchA and some capBenchS) and CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap003490 { cap003490 iff cap003490c }
check CapBenchEquivalent_cap003490 for 4
