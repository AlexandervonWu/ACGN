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

pred cap000177 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv1 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA))) }
pred cap000177c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv1 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA))) }
assert CapBenchEquivalent_cap000177 { cap000177 iff cap000177c }
check CapBenchEquivalent_cap000177 for 4
