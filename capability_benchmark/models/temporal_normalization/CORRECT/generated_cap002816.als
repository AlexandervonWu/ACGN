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

pred cap002816 { not (((inv2 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some capBenchR))) until (((some CapBenchB or some capBenchS) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap002816c { ((not (inv2 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some capBenchR))) releases (not ((some CapBenchB or some capBenchS) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap002816 { cap002816 iff cap002816c }
check CapBenchEquivalent_cap002816 for 4
