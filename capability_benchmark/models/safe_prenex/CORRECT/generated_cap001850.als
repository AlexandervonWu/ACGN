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

pred cap001850 { ((some x: CapBenchA | x->x in capBenchR) and (inv13 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some capBenchS))) }
pred cap001850c { (some x: CapBenchA | (x->x in capBenchR and (inv13 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some capBenchS)))) }
assert CapBenchEquivalent_cap001850 { cap001850 iff cap001850c }
check CapBenchEquivalent_cap001850 for 4
