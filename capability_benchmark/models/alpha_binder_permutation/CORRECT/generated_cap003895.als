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

pred cap003895 { all x, y: CapBenchA | (x->y in capBenchR and (inv3 and ((no CapBenchB or some CapBenchB) and capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap003895c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv3 and ((no CapBenchB or some CapBenchB) and capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap003895 { cap003895 iff cap003895c }
check CapBenchEquivalent_cap003895 for 4
