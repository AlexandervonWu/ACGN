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

pred cap002255 { ((inv11 and ((CapBenchA in CapBenchA + CapBenchB or CapBenchA in CapBenchA + CapBenchB) and no CapBenchB)) iff ((some capBenchR and some capBenchS) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap002255c { (((not (inv11 and ((CapBenchA in CapBenchA + CapBenchB or CapBenchA in CapBenchA + CapBenchB) and no CapBenchB))) or ((some capBenchR and some capBenchS) or capBenchR in (CapBenchA -> CapBenchA))) and ((not ((some capBenchR and some capBenchS) or capBenchR in (CapBenchA -> CapBenchA))) or (inv11 and ((CapBenchA in CapBenchA + CapBenchB or CapBenchA in CapBenchA + CapBenchB) and no CapBenchB)))) }
assert CapBenchEquivalent_cap002255 { cap002255 iff cap002255c }
check CapBenchEquivalent_cap002255 for 4
