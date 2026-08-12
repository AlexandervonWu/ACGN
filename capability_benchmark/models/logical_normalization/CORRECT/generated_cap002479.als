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

pred inv1 {
all p:Person | p in Student
}

pred inv1c {
  Person in Student
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap002479 { no x: CapBenchA | (x->x in capBenchR and (inv1 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and CapBenchA in CapBenchA + CapBenchB))) }
pred cap002479c { all x: CapBenchA | not (x->x in capBenchR and (inv1 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap002479 { cap002479 iff cap002479c }
check CapBenchEquivalent_cap002479 for 4
