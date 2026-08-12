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

pred cap000290 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv13 and ((no CapBenchA and some capBenchR) and some capBenchR))) }
pred cap000290c { all alphaOuter: CapBenchA | some alphaInner: CapBenchA | (alphaOuter->alphaInner in capBenchR and (inv13 and ((no CapBenchA and some capBenchR) and some capBenchR))) }
assert CapBenchEquivalent_cap000290 { cap000290 iff cap000290c }
check CapBenchEquivalent_cap000290 for 4
