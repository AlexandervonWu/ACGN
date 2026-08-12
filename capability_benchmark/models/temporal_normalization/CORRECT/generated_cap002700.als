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

pred cap002700 { not historically ((inv2 and ((some CapBenchA and some CapBenchB) or no CapBenchB))) }
pred cap002700c { once (not (inv2 and ((some CapBenchA and some CapBenchB) or no CapBenchB))) }
assert CapBenchEquivalent_cap002700 { cap002700 iff cap002700c }
check CapBenchEquivalent_cap002700 for 4
