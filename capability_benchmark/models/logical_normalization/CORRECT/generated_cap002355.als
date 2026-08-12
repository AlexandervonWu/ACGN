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

pred cap002355 { not ((inv14 and ((no CapBenchB or some capBenchR) and some capBenchS)) and ((some CapBenchA and no CapBenchA) or some CapBenchA)) }
pred cap002355c { ((not (inv14 and ((no CapBenchB or some capBenchR) and some capBenchS))) or (not ((some CapBenchA and no CapBenchA) or some CapBenchA))) }
assert CapBenchEquivalent_cap002355 { cap002355 iff cap002355c }
check CapBenchEquivalent_cap002355 for 4
