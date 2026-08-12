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

pred cap001824 { ((some x: CapBenchA | x->x in capBenchR) and (inv3 and ((some capBenchR and some CapBenchA) or some capBenchS))) }
pred cap001824c { (some x: CapBenchA | (x->x in capBenchR and (inv3 and ((some capBenchR and some CapBenchA) or some capBenchS)))) }
assert CapBenchEquivalent_cap001824 { cap001824 iff cap001824c }
check CapBenchEquivalent_cap001824 for 4
