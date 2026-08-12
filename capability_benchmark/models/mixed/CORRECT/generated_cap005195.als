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

pred cap005195 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv2 and ((no CapBenchB or some CapBenchA) and no CapBenchB)) and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS))) }
pred cap005195c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS)) or (not (inv2 and ((no CapBenchB or some CapBenchA) and no CapBenchB)))) }
assert CapBenchEquivalent_cap005195 { cap005195 iff cap005195c }
check CapBenchEquivalent_cap005195 for 4
