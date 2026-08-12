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

pred cap001540 { ((some x: CapBenchA | x->x in capBenchR) and (inv13 and ((some CapBenchA and some capBenchS) or some CapBenchA))) }
pred cap001540c { (some x: CapBenchA | (x->x in capBenchR and (inv13 and ((some CapBenchA and some capBenchS) or some CapBenchA)))) }
assert CapBenchEquivalent_cap001540 { cap001540 iff cap001540c }
check CapBenchEquivalent_cap001540 for 4
