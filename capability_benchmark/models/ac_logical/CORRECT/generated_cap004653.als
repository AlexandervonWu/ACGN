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
Tutors in (Teacher->Student)
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

pred cap004653 { not ((inv13 and ((some CapBenchB or no CapBenchB) or no CapBenchA)) and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and some capBenchS)) }
pred cap004653c { ((not ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and some capBenchS)) or (not (inv13 and ((some CapBenchB or no CapBenchB) or no CapBenchA)))) }
assert CapBenchEquivalent_cap004653 { cap004653 iff cap004653c }
check CapBenchEquivalent_cap004653 for 4
