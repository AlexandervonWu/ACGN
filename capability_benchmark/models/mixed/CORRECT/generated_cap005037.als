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

pred cap005037 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv2 and ((some capBenchS or some capBenchR) or some CapBenchA)) and ((no CapBenchA and no CapBenchA) and no CapBenchB))) }
pred cap005037c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchA and no CapBenchA) and no CapBenchB)) or (not (inv2 and ((some capBenchS or some capBenchR) or some CapBenchA)))) }
assert CapBenchEquivalent_cap005037 { cap005037 iff cap005037c }
check CapBenchEquivalent_cap005037 for 4
