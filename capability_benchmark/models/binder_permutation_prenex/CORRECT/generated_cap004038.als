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

pred cap004038 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv14 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some CapBenchA))) }
pred cap004038c { some a, b: CapBenchA | (b->a in capBenchR and (inv14 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some CapBenchA))) }
assert CapBenchEquivalent_cap004038 { cap004038 iff cap004038c }
check CapBenchEquivalent_cap004038 for 4
