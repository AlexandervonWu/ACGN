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

pred cap005476 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv2 and ((some capBenchR and no CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) and ((some CapBenchB or some CapBenchB) or no CapBenchA))) }
pred cap005476c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchB or some CapBenchB) or no CapBenchA)) or (not (inv2 and ((some capBenchR and no CapBenchB) or CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap005476 { cap005476 iff cap005476c }
check CapBenchEquivalent_cap005476 for 4
