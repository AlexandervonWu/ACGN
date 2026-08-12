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
all p:Person | p not in Teacher
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

pred cap002598 { not historically ((inv2 and ((no CapBenchA and some capBenchR) and some CapBenchB))) }
pred cap002598c { once (not (inv2 and ((no CapBenchA and some capBenchR) and some CapBenchB))) }
assert CapBenchEquivalent_cap002598 { cap002598 iff cap002598c }
check CapBenchEquivalent_cap002598 for 4
