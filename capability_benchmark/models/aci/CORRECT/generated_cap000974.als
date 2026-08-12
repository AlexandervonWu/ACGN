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

pred cap000974 { ((inv14 and ((no CapBenchA and no CapBenchB) and CapBenchA in CapBenchA + CapBenchB)) and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and no CapBenchA) and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR)) }
pred cap000974c { (((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR) and (inv14 and ((no CapBenchA and no CapBenchB) and CapBenchA in CapBenchA + CapBenchB)) and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and no CapBenchA)) }
assert CapBenchEquivalent_cap000974 { cap000974 iff cap000974c }
check CapBenchEquivalent_cap000974 for 4
