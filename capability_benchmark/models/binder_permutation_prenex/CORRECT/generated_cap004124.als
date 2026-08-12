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
Person = Student
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

pred cap004124 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv1 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some CapBenchB))) }
pred cap004124c { some a, b: CapBenchA | (b->a in capBenchR and (inv1 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some CapBenchB))) }
assert CapBenchEquivalent_cap004124 { cap004124 iff cap004124c }
check CapBenchEquivalent_cap004124 for 4
