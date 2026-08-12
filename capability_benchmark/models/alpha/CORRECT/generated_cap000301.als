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

pred cap000301 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv3 and ((some capBenchS or some capBenchS) or some capBenchR))) }
pred cap000301c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv3 and ((some capBenchS or some capBenchS) or some capBenchR))) }
assert CapBenchEquivalent_cap000301 { cap000301 iff cap000301c }
check CapBenchEquivalent_cap000301 for 4
