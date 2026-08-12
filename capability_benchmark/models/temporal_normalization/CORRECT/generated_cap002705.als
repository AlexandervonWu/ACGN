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

pred cap002705 { not eventually ((inv13 and ((some capBenchS or some CapBenchB) or no CapBenchB))) }
pred cap002705c { always (not (inv13 and ((some capBenchS or some CapBenchB) or no CapBenchB))) }
assert CapBenchEquivalent_cap002705 { cap002705 iff cap002705c }
check CapBenchEquivalent_cap002705 for 4
