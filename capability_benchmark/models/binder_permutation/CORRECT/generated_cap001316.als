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

pred cap001316 { all x, y: CapBenchA | (x->y in capBenchR and (inv13 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some capBenchR))) }
pred cap001316c { all a, b: CapBenchA | (b->a in capBenchR and (inv13 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some capBenchR))) }
assert CapBenchEquivalent_cap001316 { cap001316 iff cap001316c }
check CapBenchEquivalent_cap001316 for 4
