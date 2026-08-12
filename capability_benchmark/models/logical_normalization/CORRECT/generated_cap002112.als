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

pred inv10 {
all c : Class, s : Student | some g : Group | c->s->g in Groups
}

pred inv10c {
  all c:Class,s:Student | some s.(c.Groups)
}

check correct { inv10 <=> inv10c}
pred under { inv10 and !inv10c}
pred over { !inv10 and inv10c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap002112 { not (all x: CapBenchA | (x->x in capBenchR and (inv10 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB)))) }
pred cap002112c { some x: CapBenchA | not (x->x in capBenchR and (inv10 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB))) }
assert CapBenchEquivalent_cap002112 { cap002112 iff cap002112c }
check CapBenchEquivalent_cap002112 for 4
