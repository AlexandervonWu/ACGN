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

pred cap001357 { some x, y, z: CapBenchA | (x->y in capBenchR and y->z in capBenchR and (inv15 and ((some capBenchS or some capBenchR) or some capBenchS))) }
pred cap001357c { some a, b, c: CapBenchA | (c->b in capBenchR and b->a in capBenchR and (inv15 and ((some capBenchS or some capBenchR) or some capBenchS))) }
assert CapBenchEquivalent_cap001357 { cap001357 iff cap001357c }
check CapBenchEquivalent_cap001357 for 4
