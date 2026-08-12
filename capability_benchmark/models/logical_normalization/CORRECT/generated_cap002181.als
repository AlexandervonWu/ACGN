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

pred cap002181 { not ((inv13 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA)) and ((no CapBenchA and some capBenchR) and some capBenchS)) }
pred cap002181c { ((not (inv13 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA))) or (not ((no CapBenchA and some capBenchR) and some capBenchS))) }
assert CapBenchEquivalent_cap002181 { cap002181 iff cap002181c }
check CapBenchEquivalent_cap002181 for 4
