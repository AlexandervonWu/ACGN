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

pred cap001701 { ((all x: CapBenchA | x->x in capBenchR) or (inv11 and ((some CapBenchB or some CapBenchB) or no CapBenchB))) }
pred cap001701c { (all x: CapBenchA | (x->x in capBenchR or (inv11 and ((some CapBenchB or some CapBenchB) or no CapBenchB)))) }
assert CapBenchEquivalent_cap001701 { cap001701 iff cap001701c }
check CapBenchEquivalent_cap001701 for 4
