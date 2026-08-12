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

pred cap003294 { all x: CapBenchA | (x->x in capBenchR and (inv13 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some capBenchR)) and ((no CapBenchB or no CapBenchA) and CapBenchA in CapBenchA + CapBenchB)) }
pred cap003294c { all renamed: CapBenchA | (((no CapBenchB or no CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and renamed->renamed in capBenchR and (inv13 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some capBenchR))) }
assert CapBenchEquivalent_cap003294 { cap003294 iff cap003294c }
check CapBenchEquivalent_cap003294 for 4
