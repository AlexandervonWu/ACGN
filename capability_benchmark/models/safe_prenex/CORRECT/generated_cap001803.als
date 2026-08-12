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

pred cap001803 { ((all x: CapBenchA | x->x in capBenchR) or (inv13 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some capBenchR))) }
pred cap001803c { (all x: CapBenchA | (x->x in capBenchR or (inv13 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some capBenchR)))) }
assert CapBenchEquivalent_cap001803 { cap001803 iff cap001803c }
check CapBenchEquivalent_cap001803 for 4
