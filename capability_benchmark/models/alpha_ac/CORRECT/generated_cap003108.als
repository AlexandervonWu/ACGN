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
all c : Course | some teaches.c
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

pred cap003108 { all x: CapBenchA | (x->x in capBenchR and (inv3 and ((some capBenchR and some capBenchS) or some CapBenchB)) and ((some CapBenchB or no CapBenchB) or some capBenchR)) }
pred cap003108c { all renamed: CapBenchA | (((some CapBenchB or no CapBenchB) or some capBenchR) and renamed->renamed in capBenchR and (inv3 and ((some capBenchR and some capBenchS) or some CapBenchB))) }
assert CapBenchEquivalent_cap003108 { cap003108 iff cap003108c }
check CapBenchEquivalent_cap003108 for 4
