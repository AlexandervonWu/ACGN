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

pred cap004601 { not ((inv2 and ((some capBenchS or some capBenchR) or some CapBenchB)) and ((no CapBenchA and no CapBenchA) and some capBenchR)) }
pred cap004601c { ((not ((no CapBenchA and no CapBenchA) and some capBenchR)) or (not (inv2 and ((some capBenchS or some capBenchR) or some CapBenchB)))) }
assert CapBenchEquivalent_cap004601 { cap004601 iff cap004601c }
check CapBenchEquivalent_cap004601 for 4
