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

pred cap004662 { not ((inv13 and ((no CapBenchA and some capBenchR) and no CapBenchA)) and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and some capBenchS)) }
pred cap004662c { ((not ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and some capBenchS)) or (not (inv13 and ((no CapBenchA and some capBenchR) and no CapBenchA)))) }
assert CapBenchEquivalent_cap004662 { cap004662 iff cap004662c }
check CapBenchEquivalent_cap004662 for 4
