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

pred cap003090 { all x: CapBenchA | (x->x in capBenchR and (inv13 and ((no CapBenchA and no CapBenchB) and some CapBenchB)) and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some capBenchR)) }
pred cap003090c { all renamed: CapBenchA | (((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some capBenchR) and renamed->renamed in capBenchR and (inv13 and ((no CapBenchA and no CapBenchB) and some CapBenchB))) }
assert CapBenchEquivalent_cap003090 { cap003090 iff cap003090c }
check CapBenchEquivalent_cap003090 for 4
