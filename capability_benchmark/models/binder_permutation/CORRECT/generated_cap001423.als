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

pred inv1 {
Person = Student
}

pred inv1c {
  Person in Student
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap001423 { some x, y, z: CapBenchA | (x->y in capBenchR and y->z in capBenchR and (inv1 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap001423c { some a, b, c: CapBenchA | (c->b in capBenchR and b->a in capBenchR and (inv1 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap001423 { cap001423 iff cap001423c }
check CapBenchEquivalent_cap001423 for 4
