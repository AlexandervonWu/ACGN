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

pred cap004828 { not ((inv11 and ((some CapBenchA and some CapBenchB) or some capBenchS)) and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap004828c { ((not ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or CapBenchA in CapBenchA + CapBenchB)) or (not (inv11 and ((some CapBenchA and some CapBenchB) or some capBenchS)))) }
assert CapBenchEquivalent_cap004828 { cap004828 iff cap004828c }
check CapBenchEquivalent_cap004828 for 4
