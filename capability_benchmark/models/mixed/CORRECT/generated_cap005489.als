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
all c : Class | (some s : Person | some g : Group | c->s->g in Groups) => some t : Teacher | t->c in Teaches
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

pred cap005489 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv11 and ((some CapBenchB or some capBenchS) or CapBenchA in CapBenchA + CapBenchB)) and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and no CapBenchA))) }
pred cap005489c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and no CapBenchA)) or (not (inv11 and ((some CapBenchB or some capBenchS) or CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap005489 { cap005489 iff cap005489c }
check CapBenchEquivalent_cap005489 for 4
