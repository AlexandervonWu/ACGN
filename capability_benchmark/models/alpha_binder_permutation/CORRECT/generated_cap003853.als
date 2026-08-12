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

pred cap003853 { all x, y: CapBenchA | (x->y in capBenchR and (inv1 and ((some CapBenchB or some capBenchR) or some capBenchS))) }
pred cap003853c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv1 and ((some CapBenchB or some capBenchR) or some capBenchS))) }
assert CapBenchEquivalent_cap003853 { cap003853 iff cap003853c }
check CapBenchEquivalent_cap003853 for 4
