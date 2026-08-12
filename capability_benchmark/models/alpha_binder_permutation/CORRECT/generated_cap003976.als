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

pred inv2 {
all p:Person | p not in Teacher
}

pred inv2c {
  no Teacher
}

check correct { inv2 <=> inv2c}
pred under { inv2 and !inv2c}
pred over { !inv2 and inv2c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap003976 { all x, y: CapBenchA | (x->y in capBenchR and (inv2 and ((some capBenchR and no CapBenchB) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap003976c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv2 and ((some capBenchR and no CapBenchB) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap003976 { cap003976 iff cap003976c }
check CapBenchEquivalent_cap003976 for 4
