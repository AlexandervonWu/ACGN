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

pred cap000501 { ((inv2 and ((some CapBenchB or some CapBenchA) or some CapBenchA)) or ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and no CapBenchA) or ((some capBenchR and no CapBenchB) or some capBenchS)) }
pred cap000501c { (((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and no CapBenchA) or ((some capBenchR and no CapBenchB) or some capBenchS) or (inv2 and ((some CapBenchB or some CapBenchA) or some CapBenchA))) }
assert CapBenchEquivalent_cap000501 { cap000501 iff cap000501c }
check CapBenchEquivalent_cap000501 for 4
