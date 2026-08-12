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

pred cap001561 { ((all x: CapBenchA | x->x in capBenchR) or (inv13 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some CapBenchA))) }
pred cap001561c { (all x: CapBenchA | (x->x in capBenchR or (inv13 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some CapBenchA)))) }
assert CapBenchEquivalent_cap001561 { cap001561 iff cap001561c }
check CapBenchEquivalent_cap001561 for 4
