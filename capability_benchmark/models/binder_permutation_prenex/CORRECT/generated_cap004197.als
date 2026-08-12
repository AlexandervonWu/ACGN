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

pred cap004197 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv2 and ((some capBenchS or some CapBenchA) or no CapBenchB))) }
pred cap004197c { some a, b: CapBenchA | (b->a in capBenchR and (inv2 and ((some capBenchS or some CapBenchA) or no CapBenchB))) }
assert CapBenchEquivalent_cap004197 { cap004197 iff cap004197c }
check CapBenchEquivalent_cap004197 for 4
