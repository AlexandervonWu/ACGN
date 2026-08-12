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

pred cap003017 { all x: CapBenchA | (x->x in capBenchR and (inv2 and ((some CapBenchB or no CapBenchA) or some CapBenchA)) and ((capBenchR in (CapBenchA -> CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and no CapBenchA)) }
pred cap003017c { all renamed: CapBenchA | (((capBenchR in (CapBenchA -> CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and no CapBenchA) and renamed->renamed in capBenchR and (inv2 and ((some CapBenchB or no CapBenchA) or some CapBenchA))) }
assert CapBenchEquivalent_cap003017 { cap003017 iff cap003017c }
check CapBenchEquivalent_cap003017 for 4
