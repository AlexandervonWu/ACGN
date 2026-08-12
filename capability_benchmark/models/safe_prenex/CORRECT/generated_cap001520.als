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

pred cap001520 { ((some x: CapBenchA | x->x in capBenchR) and (inv2 and ((some capBenchR and no CapBenchA) or some CapBenchA))) }
pred cap001520c { (some x: CapBenchA | (x->x in capBenchR and (inv2 and ((some capBenchR and no CapBenchA) or some CapBenchA)))) }
assert CapBenchEquivalent_cap001520 { cap001520 iff cap001520c }
check CapBenchEquivalent_cap001520 for 4
