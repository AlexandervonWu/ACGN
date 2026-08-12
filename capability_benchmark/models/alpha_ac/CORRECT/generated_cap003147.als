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

pred cap003147 { all x: CapBenchA | (x->x in capBenchR and (inv2 and ((no CapBenchB or no CapBenchA) and no CapBenchA)) and ((some CapBenchA and some CapBenchA) or some capBenchS)) }
pred cap003147c { all renamed: CapBenchA | (((some CapBenchA and some CapBenchA) or some capBenchS) and renamed->renamed in capBenchR and (inv2 and ((no CapBenchB or no CapBenchA) and no CapBenchA))) }
assert CapBenchEquivalent_cap003147 { cap003147 iff cap003147c }
check CapBenchEquivalent_cap003147 for 4
