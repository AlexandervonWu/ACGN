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

pred cap004016 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv2 and ((some CapBenchA and no CapBenchA) or some CapBenchA))) }
pred cap004016c { some a, b: CapBenchA | (b->a in capBenchR and (inv2 and ((some CapBenchA and no CapBenchA) or some CapBenchA))) }
assert CapBenchEquivalent_cap004016 { cap004016 iff cap004016c }
check CapBenchEquivalent_cap004016 for 4
