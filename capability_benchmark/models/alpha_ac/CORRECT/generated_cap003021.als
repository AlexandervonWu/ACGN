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

pred cap003021 { all x: CapBenchA | (x->x in capBenchR and (inv11 and ((some capBenchS or no CapBenchA) or some CapBenchA)) and ((no CapBenchA and some CapBenchA) and no CapBenchB)) }
pred cap003021c { all renamed: CapBenchA | (((no CapBenchA and some CapBenchA) and no CapBenchB) and renamed->renamed in capBenchR and (inv11 and ((some capBenchS or no CapBenchA) or some CapBenchA))) }
assert CapBenchEquivalent_cap003021 { cap003021 iff cap003021c }
check CapBenchEquivalent_cap003021 for 4
