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

pred cap000361 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv2 and ((some CapBenchB or some capBenchS) or some capBenchS))) }
pred cap000361c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv2 and ((some CapBenchB or some capBenchS) or some capBenchS))) }
assert CapBenchEquivalent_cap000361 { cap000361 iff cap000361c }
check CapBenchEquivalent_cap000361 for 4
