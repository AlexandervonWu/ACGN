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

pred cap004702 { not ((inv2 and ((no CapBenchA and some CapBenchB) and no CapBenchB)) and ((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some capBenchS)) }
pred cap004702c { ((not ((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some capBenchS)) or (not (inv2 and ((no CapBenchA and some CapBenchB) and no CapBenchB)))) }
assert CapBenchEquivalent_cap004702 { cap004702 iff cap004702c }
check CapBenchEquivalent_cap004702 for 4
