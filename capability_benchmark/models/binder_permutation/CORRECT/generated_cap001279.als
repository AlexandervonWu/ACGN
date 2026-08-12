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
Person.Tutors in Student and Tutors.Person in Teacher
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

pred cap001279 { some x, y, z: CapBenchA | (x->y in capBenchR and y->z in capBenchR and (inv13 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some capBenchR))) }
pred cap001279c { some a, b, c: CapBenchA | (c->b in capBenchR and b->a in capBenchR and (inv13 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some capBenchR))) }
assert CapBenchEquivalent_cap001279 { cap001279 iff cap001279c }
check CapBenchEquivalent_cap001279 for 4
