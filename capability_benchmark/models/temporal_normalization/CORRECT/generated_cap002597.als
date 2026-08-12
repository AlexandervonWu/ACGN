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

pred cap002597 { not eventually ((inv2 and ((some CapBenchB or some capBenchR) or some CapBenchB))) }
pred cap002597c { always (not (inv2 and ((some CapBenchB or some capBenchR) or some CapBenchB))) }
assert CapBenchEquivalent_cap002597 { cap002597 iff cap002597c }
check CapBenchEquivalent_cap002597 for 4
