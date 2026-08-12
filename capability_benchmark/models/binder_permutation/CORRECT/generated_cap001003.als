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

pred inv15 {
all p:Person | some (^Tutors.p & Teacher)
}

pred inv15c {
  all p:Person | some Teacher&(^Tutors).p
}

check correct { inv15 <=> inv15c}
pred under { inv15 and !inv15c}
pred over { !inv15 and inv15c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap001003 { some x, y, z: CapBenchA | (x->y in capBenchR and y->z in capBenchR and (inv15 and ((no CapBenchB or some CapBenchA) and some CapBenchA))) }
pred cap001003c { some a, b, c: CapBenchA | (c->b in capBenchR and b->a in capBenchR and (inv15 and ((no CapBenchB or some CapBenchA) and some CapBenchA))) }
assert CapBenchEquivalent_cap001003 { cap001003 iff cap001003c }
check CapBenchEquivalent_cap001003 for 4
