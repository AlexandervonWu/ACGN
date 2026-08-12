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

pred cap004459 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv2 and ((no CapBenchB or some CapBenchB) and CapBenchA in CapBenchA + CapBenchB))) }
pred cap004459c { some a, b: CapBenchA | (b->a in capBenchR and (inv2 and ((no CapBenchB or some CapBenchB) and CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap004459 { cap004459 iff cap004459c }
check CapBenchEquivalent_cap004459 for 4
