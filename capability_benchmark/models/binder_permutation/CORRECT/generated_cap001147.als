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

pred inv7 {
all c : Class | some (Teaches.c & Teacher)
}

pred inv7c {
  all c:Class | some Teacher&Teaches.c
}

check correct { inv7 <=> inv7c}
pred under { inv7 and !inv7c}
pred over { !inv7 and inv7c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap001147 { some x, y, z: CapBenchA | (x->y in capBenchR and y->z in capBenchR and (inv7 and ((no CapBenchB or no CapBenchA) and no CapBenchA))) }
pred cap001147c { some a, b, c: CapBenchA | (c->b in capBenchR and b->a in capBenchR and (inv7 and ((no CapBenchB or no CapBenchA) and no CapBenchA))) }
assert CapBenchEquivalent_cap001147 { cap001147 iff cap001147c }
check CapBenchEquivalent_cap001147 for 4
