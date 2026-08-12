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

pred cap001292 { all x, y: CapBenchA | (x->y in capBenchR and (inv11 and ((some capBenchR and some capBenchR) or some capBenchR))) }
pred cap001292c { all a, b: CapBenchA | (b->a in capBenchR and (inv11 and ((some capBenchR and some capBenchR) or some capBenchR))) }
assert CapBenchEquivalent_cap001292 { cap001292 iff cap001292c }
check CapBenchEquivalent_cap001292 for 4
