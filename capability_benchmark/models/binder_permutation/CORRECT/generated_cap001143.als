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

pred inv4 {
no ((Person-Student)-Teacher)
}

pred inv4c {
 Person in Student + Teacher
}

check correct { inv4 <=> inv4c}
pred under { inv4 and !inv4c}
pred over { !inv4 and inv4c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap001143 { some x, y, z: CapBenchA | (x->y in capBenchR and y->z in capBenchR and (inv4 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and no CapBenchA))) }
pred cap001143c { some a, b, c: CapBenchA | (c->b in capBenchR and b->a in capBenchR and (inv4 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and no CapBenchA))) }
assert CapBenchEquivalent_cap001143 { cap001143 iff cap001143c }
check CapBenchEquivalent_cap001143 for 4
