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

pred cap004151 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv1 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and no CapBenchA))) }
pred cap004151c { some a, b: CapBenchA | (b->a in capBenchR and (inv1 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and no CapBenchA))) }
assert CapBenchEquivalent_cap004151 { cap004151 iff cap004151c }
check CapBenchEquivalent_cap004151 for 4
