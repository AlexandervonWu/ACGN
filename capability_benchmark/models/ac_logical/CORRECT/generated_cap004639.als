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

pred cap004639 { not ((inv14 and ((no CapBenchB or some CapBenchB) and no CapBenchA)) and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some capBenchR)) }
pred cap004639c { ((not ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some capBenchR)) or (not (inv14 and ((no CapBenchB or some CapBenchB) and no CapBenchA)))) }
assert CapBenchEquivalent_cap004639 { cap004639 iff cap004639c }
check CapBenchEquivalent_cap004639 for 4
