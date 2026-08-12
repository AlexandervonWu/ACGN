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

pred cap000637 { (some ((CapBenchA + CapBenchB) + CapBenchA) and (inv13 and ((some CapBenchB or some CapBenchB) or no CapBenchA))) }
pred cap000637c { (some (CapBenchA + (CapBenchB + CapBenchA)) and (inv13 and ((some CapBenchB or some CapBenchB) or no CapBenchA))) }
assert CapBenchEquivalent_cap000637 { cap000637 iff cap000637c }
check CapBenchEquivalent_cap000637 for 4
