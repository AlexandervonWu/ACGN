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

pred cap004994 { not ((inv11 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and CapBenchA in CapBenchA + CapBenchB)) and ((no CapBenchB or no CapBenchB) and no CapBenchA)) }
pred cap004994c { ((not ((no CapBenchB or no CapBenchB) and no CapBenchA)) or (not (inv11 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap004994 { cap004994 iff cap004994c }
check CapBenchEquivalent_cap004994 for 4
