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

pred cap002169 { not ((inv2 and ((some CapBenchB or some capBenchS) or no CapBenchA)) and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some capBenchS)) }
pred cap002169c { ((not (inv2 and ((some CapBenchB or some capBenchS) or no CapBenchA))) or (not ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some capBenchS))) }
assert CapBenchEquivalent_cap002169 { cap002169 iff cap002169c }
check CapBenchEquivalent_cap002169 for 4
