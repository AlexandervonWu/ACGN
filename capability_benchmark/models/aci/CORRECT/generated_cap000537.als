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

pred cap000537 { ((inv2 and ((some capBenchS or some capBenchR) or some CapBenchA)) or ((no CapBenchA and no CapBenchA) and no CapBenchB) or ((some CapBenchA and some CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap000537c { (((no CapBenchA and no CapBenchA) and no CapBenchB) or ((some CapBenchA and some CapBenchA) or capBenchR in (CapBenchA -> CapBenchA)) or (inv2 and ((some capBenchS or some capBenchR) or some CapBenchA))) }
assert CapBenchEquivalent_cap000537 { cap000537 iff cap000537c }
check CapBenchEquivalent_cap000537 for 4
