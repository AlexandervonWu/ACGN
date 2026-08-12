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

pred cap003832 { all x, y: CapBenchA | (x->y in capBenchR and (inv1 and ((some capBenchR and some CapBenchB) or some capBenchS))) }
pred cap003832c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv1 and ((some capBenchR and some CapBenchB) or some capBenchS))) }
assert CapBenchEquivalent_cap003832 { cap003832 iff cap003832c }
check CapBenchEquivalent_cap003832 for 4
