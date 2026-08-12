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

pred cap003852 { all x, y: CapBenchA | (x->y in capBenchR and (inv13 and ((some CapBenchA and some capBenchR) or some capBenchS))) }
pred cap003852c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv13 and ((some CapBenchA and some capBenchR) or some capBenchS))) }
assert CapBenchEquivalent_cap003852 { cap003852 iff cap003852c }
check CapBenchEquivalent_cap003852 for 4
