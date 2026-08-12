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

pred cap005310 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and some capBenchR)) and ((no CapBenchB or some capBenchR) and CapBenchA in CapBenchA + CapBenchB))) }
pred cap005310c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchB or some capBenchR) and CapBenchA in CapBenchA + CapBenchB)) or (not (inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and some capBenchR)))) }
assert CapBenchEquivalent_cap005310 { cap005310 iff cap005310c }
check CapBenchEquivalent_cap005310 for 4
