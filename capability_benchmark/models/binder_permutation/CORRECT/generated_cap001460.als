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

pred cap001460 { all x, y: CapBenchA | (x->y in capBenchR and (inv2 and ((some capBenchR and some CapBenchB) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap001460c { all a, b: CapBenchA | (b->a in capBenchR and (inv2 and ((some capBenchR and some CapBenchB) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap001460 { cap001460 iff cap001460c }
check CapBenchEquivalent_cap001460 for 4
