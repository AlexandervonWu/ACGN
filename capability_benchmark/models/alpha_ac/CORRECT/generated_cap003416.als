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

pred cap003416 { all x: CapBenchA | (x->x in capBenchR and (inv14 and ((some CapBenchA and some capBenchR) or capBenchR in (CapBenchA -> CapBenchA))) and ((some capBenchS or some CapBenchB) or some CapBenchB)) }
pred cap003416c { all renamed: CapBenchA | (((some capBenchS or some CapBenchB) or some CapBenchB) and renamed->renamed in capBenchR and (inv14 and ((some CapBenchA and some capBenchR) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap003416 { cap003416 iff cap003416c }
check CapBenchEquivalent_cap003416 for 4
