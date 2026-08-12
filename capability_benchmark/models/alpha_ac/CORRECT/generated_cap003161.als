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

pred cap003161 { all x: CapBenchA | (x->x in capBenchR and (inv3 and ((some CapBenchB or some capBenchR) or no CapBenchA)) and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some capBenchS)) }
pred cap003161c { all renamed: CapBenchA | (((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some capBenchS) and renamed->renamed in capBenchR and (inv3 and ((some CapBenchB or some capBenchR) or no CapBenchA))) }
assert CapBenchEquivalent_cap003161 { cap003161 iff cap003161c }
check CapBenchEquivalent_cap003161 for 4
