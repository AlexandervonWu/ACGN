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

pred cap004079 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv1 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and some CapBenchB))) }
pred cap004079c { some a, b: CapBenchA | (b->a in capBenchR and (inv1 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and some CapBenchB))) }
assert CapBenchEquivalent_cap004079 { cap004079 iff cap004079c }
check CapBenchEquivalent_cap004079 for 4
