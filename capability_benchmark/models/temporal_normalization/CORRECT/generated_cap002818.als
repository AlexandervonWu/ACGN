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

pred cap002818 { not always ((inv11 and ((capBenchR in (CapBenchA -> CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and some capBenchR))) }
pred cap002818c { eventually (not (inv11 and ((capBenchR in (CapBenchA -> CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and some capBenchR))) }
assert CapBenchEquivalent_cap002818 { cap002818 iff cap002818c }
check CapBenchEquivalent_cap002818 for 4
