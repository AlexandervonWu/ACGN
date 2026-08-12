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

pred cap002825 { not eventually ((inv2 and ((some capBenchS or some CapBenchA) or some capBenchS))) }
pred cap002825c { always (not (inv2 and ((some capBenchS or some CapBenchA) or some capBenchS))) }
assert CapBenchEquivalent_cap002825 { cap002825 iff cap002825c }
check CapBenchEquivalent_cap002825 for 4
