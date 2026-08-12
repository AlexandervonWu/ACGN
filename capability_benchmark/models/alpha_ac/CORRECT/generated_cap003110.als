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

pred cap003110 { all x: CapBenchA | (x->x in capBenchR and (inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some CapBenchB)) and ((no CapBenchB or no CapBenchB) and some capBenchR)) }
pred cap003110c { all renamed: CapBenchA | (((no CapBenchB or no CapBenchB) and some capBenchR) and renamed->renamed in capBenchR and (inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some CapBenchB))) }
assert CapBenchEquivalent_cap003110 { cap003110 iff cap003110c }
check CapBenchEquivalent_cap003110 for 4
