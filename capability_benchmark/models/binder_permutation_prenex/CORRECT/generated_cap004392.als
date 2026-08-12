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

pred cap004392 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv10 and ((some CapBenchA and some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap004392c { some a, b: CapBenchA | (b->a in capBenchR and (inv10 and ((some CapBenchA and some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap004392 { cap004392 iff cap004392c }
check CapBenchEquivalent_cap004392 for 4
