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

pred cap001592 { ((some x: CapBenchA | x->x in capBenchR) and (inv13 and ((some capBenchR and no CapBenchB) or some CapBenchB))) }
pred cap001592c { (some x: CapBenchA | (x->x in capBenchR and (inv13 and ((some capBenchR and no CapBenchB) or some CapBenchB)))) }
assert CapBenchEquivalent_cap001592 { cap001592 iff cap001592c }
check CapBenchEquivalent_cap001592 for 4
