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

pred cap001285 { some x, y, z: CapBenchA | (x->y in capBenchR and y->z in capBenchR and (inv13 and ((some capBenchS or no CapBenchB) or some capBenchR))) }
pred cap001285c { some a, b, c: CapBenchA | (c->b in capBenchR and b->a in capBenchR and (inv13 and ((some capBenchS or no CapBenchB) or some capBenchR))) }
assert CapBenchEquivalent_cap001285 { cap001285 iff cap001285c }
check CapBenchEquivalent_cap001285 for 4
