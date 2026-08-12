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

pred cap004798 { not ((inv2 and ((no CapBenchA and some capBenchS) and some capBenchR)) and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and CapBenchA in CapBenchA + CapBenchB)) }
pred cap004798c { ((not ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and CapBenchA in CapBenchA + CapBenchB)) or (not (inv2 and ((no CapBenchA and some capBenchS) and some capBenchR)))) }
assert CapBenchEquivalent_cap004798 { cap004798 iff cap004798c }
check CapBenchEquivalent_cap004798 for 4
