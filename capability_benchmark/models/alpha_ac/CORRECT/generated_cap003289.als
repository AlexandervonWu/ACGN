sig Person  {
	Tutors : set Person,
	Teaches : set Class
}
sig Group {}

sig Class  {
	Groups : Person -> Group
}

sig Teacher in Person  {}

sig Student in Person  {}

pred inv3 {
all x: Person | x in Student implies x not in Teacher
}

pred inv3c {
 no Student & Teacher 
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap003289 { all x: CapBenchA | (x->x in capBenchR and (inv3 and ((some CapBenchB or some capBenchR) or some capBenchR)) and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and CapBenchA in CapBenchA + CapBenchB)) }
pred cap003289c { all renamed: CapBenchA | (((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and CapBenchA in CapBenchA + CapBenchB) and renamed->renamed in capBenchR and (inv3 and ((some CapBenchB or some capBenchR) or some capBenchR))) }
assert CapBenchEquivalent_cap003289 { cap003289 iff cap003289c }
check CapBenchEquivalent_cap003289 for 4
