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

pred cap000885 { ((inv2 and ((some CapBenchB or some CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))) or ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some CapBenchA) or ((some capBenchR and no CapBenchB) or no CapBenchB)) }
pred cap000885c { (((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some CapBenchA) or ((some capBenchR and no CapBenchB) or no CapBenchB) or (inv2 and ((some CapBenchB or some CapBenchA) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap000885 { cap000885 iff cap000885c }
check CapBenchEquivalent_cap000885 for 4
