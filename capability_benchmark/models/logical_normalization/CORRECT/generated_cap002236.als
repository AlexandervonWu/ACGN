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

pred cap002236 { ((inv14 and ((some capBenchR and some capBenchS) or no CapBenchB)) implies ((some CapBenchB or no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap002236c { ((not (inv14 and ((some capBenchR and some capBenchS) or no CapBenchB))) or ((some CapBenchB or no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) }
assert CapBenchEquivalent_cap002236 { cap002236 iff cap002236c }
check CapBenchEquivalent_cap002236 for 4
