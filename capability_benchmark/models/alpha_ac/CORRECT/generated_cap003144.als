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

pred cap003144 { all x: CapBenchA | (x->x in capBenchR and (inv11 and ((some CapBenchA and no CapBenchA) or no CapBenchA)) and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some capBenchR)) }
pred cap003144c { all renamed: CapBenchA | (((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some capBenchR) and renamed->renamed in capBenchR and (inv11 and ((some CapBenchA and no CapBenchA) or no CapBenchA))) }
assert CapBenchEquivalent_cap003144 { cap003144 iff cap003144c }
check CapBenchEquivalent_cap003144 for 4
