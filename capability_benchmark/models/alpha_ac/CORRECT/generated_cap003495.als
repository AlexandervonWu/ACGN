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

pred cap003495 { all x: CapBenchA | (x->x in capBenchR and (inv11 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and CapBenchA in CapBenchA + CapBenchB)) and ((some capBenchR and no CapBenchB) or no CapBenchA)) }
pred cap003495c { all renamed: CapBenchA | (((some capBenchR and no CapBenchB) or no CapBenchA) and renamed->renamed in capBenchR and (inv11 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap003495 { cap003495 iff cap003495c }
check CapBenchEquivalent_cap003495 for 4
