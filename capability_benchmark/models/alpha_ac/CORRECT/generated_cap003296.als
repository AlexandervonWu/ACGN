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

pred cap003296 { all x: CapBenchA | (x->x in capBenchR and (inv13 and ((some CapBenchA and some capBenchS) or some capBenchR)) and ((some capBenchS or no CapBenchA) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap003296c { all renamed: CapBenchA | (((some capBenchS or no CapBenchA) or CapBenchA in CapBenchA + CapBenchB) and renamed->renamed in capBenchR and (inv13 and ((some CapBenchA and some capBenchS) or some capBenchR))) }
assert CapBenchEquivalent_cap003296 { cap003296 iff cap003296c }
check CapBenchEquivalent_cap003296 for 4
