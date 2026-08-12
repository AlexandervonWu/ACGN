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
all c: Class | some Person.(c.Groups) implies some t:Teacher | t in Teaches.c
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

pred cap001203 { some x, y, z: CapBenchA | (x->y in capBenchR and y->z in capBenchR and (inv11 and ((no CapBenchB or some CapBenchB) and no CapBenchB))) }
pred cap001203c { some a, b, c: CapBenchA | (c->b in capBenchR and b->a in capBenchR and (inv11 and ((no CapBenchB or some CapBenchB) and no CapBenchB))) }
assert CapBenchEquivalent_cap001203 { cap001203 iff cap001203c }
check CapBenchEquivalent_cap001203 for 4
