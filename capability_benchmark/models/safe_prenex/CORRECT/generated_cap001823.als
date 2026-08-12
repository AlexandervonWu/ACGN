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

pred cap001823 { ((all x: CapBenchA | x->x in capBenchR) or (inv2 and ((no CapBenchB or some CapBenchA) and some capBenchS))) }
pred cap001823c { (all x: CapBenchA | (x->x in capBenchR or (inv2 and ((no CapBenchB or some CapBenchA) and some capBenchS)))) }
assert CapBenchEquivalent_cap001823 { cap001823 iff cap001823c }
check CapBenchEquivalent_cap001823 for 4
