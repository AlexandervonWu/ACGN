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

pred cap002919 { not (((inv13 and ((no CapBenchB or some capBenchR) and capBenchR in (CapBenchA -> CapBenchA)))) since (((some CapBenchA and no CapBenchA) or some CapBenchB))) }
pred cap002919c { ((not (inv13 and ((no CapBenchB or some capBenchR) and capBenchR in (CapBenchA -> CapBenchA)))) triggered (not ((some CapBenchA and no CapBenchA) or some CapBenchB))) }
assert CapBenchEquivalent_cap002919 { cap002919 iff cap002919c }
check CapBenchEquivalent_cap002919 for 4
