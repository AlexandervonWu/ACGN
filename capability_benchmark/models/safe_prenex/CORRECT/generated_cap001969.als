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

pred cap001969 { ((all x: CapBenchA | x->x in capBenchR) or (inv13 and ((some capBenchS or no CapBenchA) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap001969c { (all x: CapBenchA | (x->x in capBenchR or (inv13 and ((some capBenchS or no CapBenchA) or CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap001969 { cap001969 iff cap001969c }
check CapBenchEquivalent_cap001969 for 4
