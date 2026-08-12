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

pred cap001034 { all x, y: CapBenchA | (x->y in capBenchR and (inv2 and ((no CapBenchA and some capBenchR) and some CapBenchA))) }
pred cap001034c { all a, b: CapBenchA | (b->a in capBenchR and (inv2 and ((no CapBenchA and some capBenchR) and some CapBenchA))) }
assert CapBenchEquivalent_cap001034 { cap001034 iff cap001034c }
check CapBenchEquivalent_cap001034 for 4
