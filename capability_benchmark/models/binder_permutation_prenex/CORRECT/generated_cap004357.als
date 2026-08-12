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

pred cap004357 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv14 and ((some capBenchS or some capBenchR) or some capBenchS))) }
pred cap004357c { some a, b: CapBenchA | (b->a in capBenchR and (inv14 and ((some capBenchS or some capBenchR) or some capBenchS))) }
assert CapBenchEquivalent_cap004357 { cap004357 iff cap004357c }
check CapBenchEquivalent_cap004357 for 4
