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
all p : Person | p not in Teacher
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

pred cap003708 { all x, y: CapBenchA | (x->y in capBenchR and (inv2 and ((some CapBenchA and no CapBenchA) or no CapBenchB))) }
pred cap003708c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv2 and ((some CapBenchA and no CapBenchA) or no CapBenchB))) }
assert CapBenchEquivalent_cap003708 { cap003708 iff cap003708c }
check CapBenchEquivalent_cap003708 for 4
