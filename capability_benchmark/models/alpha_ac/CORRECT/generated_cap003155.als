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

pred cap003155 { all x: CapBenchA | (x->x in capBenchR and (inv2 and ((no CapBenchB or no CapBenchB) and no CapBenchA)) and ((some CapBenchA and some CapBenchB) or some capBenchS)) }
pred cap003155c { all renamed: CapBenchA | (((some CapBenchA and some CapBenchB) or some capBenchS) and renamed->renamed in capBenchR and (inv2 and ((no CapBenchB or no CapBenchB) and no CapBenchA))) }
assert CapBenchEquivalent_cap003155 { cap003155 iff cap003155c }
check CapBenchEquivalent_cap003155 for 4
