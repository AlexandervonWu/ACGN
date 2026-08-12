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

pred cap000339 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv14 and ((no CapBenchB or no CapBenchA) and some capBenchS))) }
pred cap000339c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv14 and ((no CapBenchB or no CapBenchA) and some capBenchS))) }
assert CapBenchEquivalent_cap000339 { cap000339 iff cap000339c }
check CapBenchEquivalent_cap000339 for 4
