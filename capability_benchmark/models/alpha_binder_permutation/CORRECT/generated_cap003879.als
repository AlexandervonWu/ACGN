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

pred inv13 {
Tutors in (Teacher->Student)
}

pred inv13c {
  Tutors in Teacher -> Student
}

check correct { inv13 <=> inv13c}
pred under { inv13 and !inv13c}
pred over { !inv13 and inv13c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap003879 { all x, y: CapBenchA | (x->y in capBenchR and (inv13 and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some capBenchS))) }
pred cap003879c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv13 and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some capBenchS))) }
assert CapBenchEquivalent_cap003879 { cap003879 iff cap003879c }
check CapBenchEquivalent_cap003879 for 4
