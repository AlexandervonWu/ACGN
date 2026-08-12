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

pred cap001766 { ((some x: CapBenchA | x->x in capBenchR) and (inv2 and ((no CapBenchA and some CapBenchB) and some capBenchR))) }
pred cap001766c { (some x: CapBenchA | (x->x in capBenchR and (inv2 and ((no CapBenchA and some CapBenchB) and some capBenchR)))) }
assert CapBenchEquivalent_cap001766 { cap001766 iff cap001766c }
check CapBenchEquivalent_cap001766 for 4
