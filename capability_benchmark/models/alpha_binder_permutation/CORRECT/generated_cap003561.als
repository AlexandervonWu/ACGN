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
all p1,p2:Person | p2 in p1.Tutors implies p1 in Teacher and p2 in Student
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

pred cap003561 { all x, y: CapBenchA | (x->y in capBenchR and (inv13 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some CapBenchA))) }
pred cap003561c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv13 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some CapBenchA))) }
assert CapBenchEquivalent_cap003561 { cap003561 iff cap003561c }
check CapBenchEquivalent_cap003561 for 4
