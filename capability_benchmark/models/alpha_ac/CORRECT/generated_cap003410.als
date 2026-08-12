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

pred cap003410 { all x: CapBenchA | (x->x in capBenchR and (inv2 and ((no CapBenchA and no CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))) and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some CapBenchB)) }
pred cap003410c { all renamed: CapBenchA | (((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some CapBenchB) and renamed->renamed in capBenchR and (inv2 and ((no CapBenchA and no CapBenchB) and capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap003410 { cap003410 iff cap003410c }
check CapBenchEquivalent_cap003410 for 4
