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

pred cap000881 { (inv2 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some capBenchS)) }
pred cap000881c { ((inv2 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some capBenchS)) or (inv2 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some capBenchS))) }
assert CapBenchEquivalent_cap000881 { cap000881 iff cap000881c }
check CapBenchEquivalent_cap000881 for 4
