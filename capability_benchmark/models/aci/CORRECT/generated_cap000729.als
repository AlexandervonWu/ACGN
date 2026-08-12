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

pred cap000729 { ((inv11 and ((some capBenchS or some capBenchR) or no CapBenchB)) or ((no CapBenchA and no CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) or ((some CapBenchA and some CapBenchA) or some CapBenchB)) }
pred cap000729c { (((no CapBenchA and no CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) or ((some CapBenchA and some CapBenchA) or some CapBenchB) or (inv11 and ((some capBenchS or some capBenchR) or no CapBenchB))) }
assert CapBenchEquivalent_cap000729 { cap000729 iff cap000729c }
check CapBenchEquivalent_cap000729 for 4
