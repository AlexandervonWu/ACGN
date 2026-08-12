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

pred cap000061 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv13 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some CapBenchA))) }
pred cap000061c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv13 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some CapBenchA))) }
assert CapBenchEquivalent_cap000061 { cap000061 iff cap000061c }
check CapBenchEquivalent_cap000061 for 4
