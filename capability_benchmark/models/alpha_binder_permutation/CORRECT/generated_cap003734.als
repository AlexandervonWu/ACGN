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

pred cap003734 { all x, y: CapBenchA | (x->y in capBenchR and (inv13 and ((no CapBenchA and some capBenchS) and no CapBenchB))) }
pred cap003734c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv13 and ((no CapBenchA and some capBenchS) and no CapBenchB))) }
assert CapBenchEquivalent_cap003734 { cap003734 iff cap003734c }
check CapBenchEquivalent_cap003734 for 4
