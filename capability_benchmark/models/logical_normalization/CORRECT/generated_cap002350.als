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

pred cap002350 { ((inv13 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some capBenchS)) implies ((no CapBenchB or some CapBenchB) and some CapBenchA)) }
pred cap002350c { ((not (inv13 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some capBenchS))) or ((no CapBenchB or some CapBenchB) and some CapBenchA)) }
assert CapBenchEquivalent_cap002350 { cap002350 iff cap002350c }
check CapBenchEquivalent_cap002350 for 4
