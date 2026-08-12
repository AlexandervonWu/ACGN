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

pred cap000904 { (inv2 and ((some capBenchR and no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap000904c { ((inv2 and ((some capBenchR and no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))) and (inv2 and ((some capBenchR and no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap000904 { cap000904 iff cap000904c }
check CapBenchEquivalent_cap000904 for 4
