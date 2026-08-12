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

pred cap000787 { (some ((CapBenchA + CapBenchB) + CapBenchA) and (inv2 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some capBenchR))) }
pred cap000787c { (some (CapBenchA + (CapBenchB + CapBenchA)) and (inv2 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some capBenchR))) }
assert CapBenchEquivalent_cap000787 { cap000787 iff cap000787c }
check CapBenchEquivalent_cap000787 for 4
