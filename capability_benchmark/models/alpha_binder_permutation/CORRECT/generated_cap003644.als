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

pred cap003644 { all x, y: CapBenchA | (x->y in capBenchR and (inv11 and ((some CapBenchA and no CapBenchA) or no CapBenchA))) }
pred cap003644c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv11 and ((some CapBenchA and no CapBenchA) or no CapBenchA))) }
assert CapBenchEquivalent_cap003644 { cap003644 iff cap003644c }
check CapBenchEquivalent_cap003644 for 4
