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

pred cap000253 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv2 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or no CapBenchB))) }
pred cap000253c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv2 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or no CapBenchB))) }
assert CapBenchEquivalent_cap000253 { cap000253 iff cap000253c }
check CapBenchEquivalent_cap000253 for 4
