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

pred cap002652 { not historically ((inv2 and ((some CapBenchA and no CapBenchB) or no CapBenchA))) }
pred cap002652c { once (not (inv2 and ((some CapBenchA and no CapBenchB) or no CapBenchA))) }
assert CapBenchEquivalent_cap002652 { cap002652 iff cap002652c }
check CapBenchEquivalent_cap002652 for 4
