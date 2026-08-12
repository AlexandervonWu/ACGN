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

pred cap003343 { all x: CapBenchA | (x->x in capBenchR and (inv13 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some capBenchS)) and ((some capBenchR and some CapBenchA) or some CapBenchA)) }
pred cap003343c { all renamed: CapBenchA | (((some capBenchR and some CapBenchA) or some CapBenchA) and renamed->renamed in capBenchR and (inv13 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some capBenchS))) }
assert CapBenchEquivalent_cap003343 { cap003343 iff cap003343c }
check CapBenchEquivalent_cap003343 for 4
