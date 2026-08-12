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

pred cap000838 { (inv2 and ((no CapBenchA and no CapBenchA) and some capBenchS)) }
pred cap000838c { ((inv2 and ((no CapBenchA and no CapBenchA) and some capBenchS)) and (inv2 and ((no CapBenchA and no CapBenchA) and some capBenchS))) }
assert CapBenchEquivalent_cap000838 { cap000838 iff cap000838c }
check CapBenchEquivalent_cap000838 for 4
