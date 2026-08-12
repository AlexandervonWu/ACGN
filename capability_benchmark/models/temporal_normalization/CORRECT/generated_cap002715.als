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

pred cap002715 { not (((inv2 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and no CapBenchB))) since (((some capBenchR and some CapBenchA) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap002715c { ((not (inv2 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and no CapBenchB))) triggered (not ((some capBenchR and some CapBenchA) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap002715 { cap002715 iff cap002715c }
check CapBenchEquivalent_cap002715 for 4
