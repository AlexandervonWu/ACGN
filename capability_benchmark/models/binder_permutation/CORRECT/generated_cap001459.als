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

pred inv14 {
all c:Class,s:Person | (some g:Group | c->s->g in Groups) implies (all t:Person | t->c in Teaches implies t->s in Tutors)
}

pred inv14c {
      all c:Class,p:Person | p in (c.Groups).Group implies Teaches.c -> p in Tutors
}

check correct { inv14 <=> inv14c}
pred under { inv14 and !inv14c}
pred over { !inv14 and inv14c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap001459 { some x, y, z: CapBenchA | (x->y in capBenchR and y->z in capBenchR and (inv14 and ((no CapBenchB or some CapBenchB) and CapBenchA in CapBenchA + CapBenchB))) }
pred cap001459c { some a, b, c: CapBenchA | (c->b in capBenchR and b->a in capBenchR and (inv14 and ((no CapBenchB or some CapBenchB) and CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap001459 { cap001459 iff cap001459c }
check CapBenchEquivalent_cap001459 for 4
