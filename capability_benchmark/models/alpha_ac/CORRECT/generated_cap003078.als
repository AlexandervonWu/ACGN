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
no Teacher
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

pred cap003078 { all x: CapBenchA | (x->x in capBenchR and (inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some CapBenchB)) and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and no CapBenchB)) }
pred cap003078c { all renamed: CapBenchA | (((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and no CapBenchB) and renamed->renamed in capBenchR and (inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some CapBenchB))) }
assert CapBenchEquivalent_cap003078 { cap003078 iff cap003078c }
check CapBenchEquivalent_cap003078 for 4
