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
all p1,p2:Person | p2 in p1.Tutors implies p1 in Teacher and p2 in Student
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

pred cap001149 { some x, y, z: CapBenchA | (x->y in capBenchR and y->z in capBenchR and (inv13 and ((some capBenchS or no CapBenchA) or no CapBenchA))) }
pred cap001149c { some a, b, c: CapBenchA | (c->b in capBenchR and b->a in capBenchR and (inv13 and ((some capBenchS or no CapBenchA) or no CapBenchA))) }
assert CapBenchEquivalent_cap001149 { cap001149 iff cap001149c }
check CapBenchEquivalent_cap001149 for 4
