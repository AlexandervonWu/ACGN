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

pred cap003411 { all x: CapBenchA | (x->x in capBenchR and (inv2 and ((no CapBenchB or no CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))) and ((some CapBenchA and some CapBenchB) or some CapBenchB)) }
pred cap003411c { all renamed: CapBenchA | (((some CapBenchA and some CapBenchB) or some CapBenchB) and renamed->renamed in capBenchR and (inv2 and ((no CapBenchB or no CapBenchB) and capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap003411 { cap003411 iff cap003411c }
check CapBenchEquivalent_cap003411 for 4
