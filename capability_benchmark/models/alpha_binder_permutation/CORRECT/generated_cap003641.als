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

pred cap003641 { all x, y: CapBenchA | (x->y in capBenchR and (inv14 and ((some capBenchS or some CapBenchB) or no CapBenchA))) }
pred cap003641c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv14 and ((some capBenchS or some CapBenchB) or no CapBenchA))) }
assert CapBenchEquivalent_cap003641 { cap003641 iff cap003641c }
check CapBenchEquivalent_cap003641 for 4
