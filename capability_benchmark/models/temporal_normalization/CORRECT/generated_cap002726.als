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

pred cap002726 { not (((inv11 and ((no CapBenchA and some capBenchR) and no CapBenchB))) until (((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap002726c { ((not (inv11 and ((no CapBenchA and some capBenchR) and no CapBenchB))) releases (not ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap002726 { cap002726 iff cap002726c }
check CapBenchEquivalent_cap002726 for 4
