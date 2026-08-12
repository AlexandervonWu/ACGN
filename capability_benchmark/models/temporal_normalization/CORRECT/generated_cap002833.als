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

pred cap002833 { not once ((inv2 and ((some capBenchS or some CapBenchB) or some capBenchS))) }
pred cap002833c { historically (not (inv2 and ((some capBenchS or some CapBenchB) or some capBenchS))) }
assert CapBenchEquivalent_cap002833 { cap002833 iff cap002833c }
check CapBenchEquivalent_cap002833 for 4
