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

pred inv11 {
all c : Class | (some c.Groups implies some (Teaches.c & Teacher))
}

pred inv11c {
  all c:Class | some c.Groups implies some Teacher&Teaches.c
}


check correct { inv11 <=> inv11c}
pred under { inv11 and !inv11c}
pred over { !inv11 and inv11c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap001137 { some x, y, z: CapBenchA | (x->y in capBenchR and y->z in capBenchR and (inv11 and ((some CapBenchB or some CapBenchB) or no CapBenchA))) }
pred cap001137c { some a, b, c: CapBenchA | (c->b in capBenchR and b->a in capBenchR and (inv11 and ((some CapBenchB or some CapBenchB) or no CapBenchA))) }
assert CapBenchEquivalent_cap001137 { cap001137 iff cap001137c }
check CapBenchEquivalent_cap001137 for 4
