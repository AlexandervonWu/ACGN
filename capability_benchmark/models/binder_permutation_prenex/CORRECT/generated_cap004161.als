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
no Teacher
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

pred cap004161 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv2 and ((some CapBenchB or some capBenchR) or no CapBenchA))) }
pred cap004161c { some a, b: CapBenchA | (b->a in capBenchR and (inv2 and ((some CapBenchB or some capBenchR) or no CapBenchA))) }
assert CapBenchEquivalent_cap004161 { cap004161 iff cap004161c }
check CapBenchEquivalent_cap004161 for 4
