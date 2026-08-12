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

pred cap000577 { (some ((CapBenchA + CapBenchB) + CapBenchA) and (inv2 and ((some capBenchS or some CapBenchB) or some CapBenchB))) }
pred cap000577c { (some (CapBenchA + (CapBenchB + CapBenchA)) and (inv2 and ((some capBenchS or some CapBenchB) or some CapBenchB))) }
assert CapBenchEquivalent_cap000577 { cap000577 iff cap000577c }
check CapBenchEquivalent_cap000577 for 4
