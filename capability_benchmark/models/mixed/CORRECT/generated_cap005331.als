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

pred cap005331 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv2 and ((no CapBenchB or some CapBenchB) and some capBenchS)) and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap005331c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) or (not (inv2 and ((no CapBenchB or some CapBenchB) and some capBenchS)))) }
assert CapBenchEquivalent_cap005331 { cap005331 iff cap005331c }
check CapBenchEquivalent_cap005331 for 4
