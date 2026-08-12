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

pred cap003087 { all x: CapBenchA | (x->x in capBenchR and (inv3 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some CapBenchB)) and ((some capBenchR and some CapBenchA) or some capBenchR)) }
pred cap003087c { all renamed: CapBenchA | (((some capBenchR and some CapBenchA) or some capBenchR) and renamed->renamed in capBenchR and (inv3 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some CapBenchB))) }
assert CapBenchEquivalent_cap003087 { cap003087 iff cap003087c }
check CapBenchEquivalent_cap003087 for 4
