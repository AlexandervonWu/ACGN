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

pred cap002989 { not once ((inv2 and ((some CapBenchB or some capBenchS) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap002989c { historically (not (inv2 and ((some CapBenchB or some capBenchS) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap002989 { cap002989 iff cap002989c }
check CapBenchEquivalent_cap002989 for 4
