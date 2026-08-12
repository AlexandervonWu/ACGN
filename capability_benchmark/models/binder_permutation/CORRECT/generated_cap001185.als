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

pred inv12 {
all t : Teacher | some t.Teaches.Groups
}

pred inv12c {
 all x:Teacher | some x.Teaches.Groups
}

check correct { inv12 <=> inv12c}
pred under { inv12 and !inv12c}
pred over { !inv12 and inv12c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap001185 { some x, y, z: CapBenchA | (x->y in capBenchR and y->z in capBenchR and (inv12 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or no CapBenchA))) }
pred cap001185c { some a, b, c: CapBenchA | (c->b in capBenchR and b->a in capBenchR and (inv12 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or no CapBenchA))) }
assert CapBenchEquivalent_cap001185 { cap001185 iff cap001185c }
check CapBenchEquivalent_cap001185 for 4
