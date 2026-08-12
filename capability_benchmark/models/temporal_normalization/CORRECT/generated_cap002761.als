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

pred cap002761 { not once ((inv13 and ((some capBenchS or some CapBenchA) or some capBenchR))) }
pred cap002761c { historically (not (inv13 and ((some capBenchS or some CapBenchA) or some capBenchR))) }
assert CapBenchEquivalent_cap002761 { cap002761 iff cap002761c }
check CapBenchEquivalent_cap002761 for 4
