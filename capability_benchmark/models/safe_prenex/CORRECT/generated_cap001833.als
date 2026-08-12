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

pred cap001833 { ((all x: CapBenchA | x->x in capBenchR) or (inv2 and ((some capBenchS or some CapBenchB) or some capBenchS))) }
pred cap001833c { (all x: CapBenchA | (x->x in capBenchR or (inv2 and ((some capBenchS or some CapBenchB) or some capBenchS)))) }
assert CapBenchEquivalent_cap001833 { cap001833 iff cap001833c }
check CapBenchEquivalent_cap001833 for 4
