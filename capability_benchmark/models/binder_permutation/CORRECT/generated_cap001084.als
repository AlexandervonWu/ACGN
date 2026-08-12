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

pred cap001084 { all x, y: CapBenchA | (x->y in capBenchR and (inv2 and ((some capBenchR and no CapBenchA) or some CapBenchB))) }
pred cap001084c { all a, b: CapBenchA | (b->a in capBenchR and (inv2 and ((some capBenchR and no CapBenchA) or some CapBenchB))) }
assert CapBenchEquivalent_cap001084 { cap001084 iff cap001084c }
check CapBenchEquivalent_cap001084 for 4
