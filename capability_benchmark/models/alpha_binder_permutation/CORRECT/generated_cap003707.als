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

pred inv4 {
no p:Person | p not in Student and p not in Teacher
}

pred inv4c {
 Person in Student + Teacher
}

check correct { inv4 <=> inv4c}
pred under { inv4 and !inv4c}
pred over { !inv4 and inv4c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap003707 { all x, y: CapBenchA | (x->y in capBenchR and (inv4 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and no CapBenchB))) }
pred cap003707c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv4 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and no CapBenchB))) }
assert CapBenchEquivalent_cap003707 { cap003707 iff cap003707c }
check CapBenchEquivalent_cap003707 for 4
