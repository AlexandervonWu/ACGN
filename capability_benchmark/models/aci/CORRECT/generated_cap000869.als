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

pred cap000869 { (inv13 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS)) }
pred cap000869c { ((inv13 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS)) or (inv13 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS))) }
assert CapBenchEquivalent_cap000869 { cap000869 iff cap000869c }
check CapBenchEquivalent_cap000869 for 4
