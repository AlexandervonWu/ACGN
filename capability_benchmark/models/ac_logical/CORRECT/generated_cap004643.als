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

pred cap004643 { not ((inv2 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and no CapBenchA)) and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some capBenchR)) }
pred cap004643c { ((not ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some capBenchR)) or (not (inv2 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and no CapBenchA)))) }
assert CapBenchEquivalent_cap004643 { cap004643 iff cap004643c }
check CapBenchEquivalent_cap004643 for 4
