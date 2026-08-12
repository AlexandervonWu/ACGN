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

pred cap001199 { some x, y, z: CapBenchA | (x->y in capBenchR and y->z in capBenchR and (inv10 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and no CapBenchB))) }
pred cap001199c { some a, b, c: CapBenchA | (c->b in capBenchR and b->a in capBenchR and (inv10 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and no CapBenchB))) }
assert CapBenchEquivalent_cap001199 { cap001199 iff cap001199c }
check CapBenchEquivalent_cap001199 for 4
