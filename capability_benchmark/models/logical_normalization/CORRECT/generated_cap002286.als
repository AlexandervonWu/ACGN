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

pred inv4 {
no p:Person | p not in Student and p not in Teacher
}

pred inv4c {
 Person in Student + Teacher
}

check correct { inv4 <=> inv4c}
pred under { inv4 and !inv4c}
pred over { !inv4 and inv4c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap002286 { not (all x: CapBenchA | (x->x in capBenchR and (inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some capBenchR)))) }
pred cap002286c { some x: CapBenchA | not (x->x in capBenchR and (inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some capBenchR))) }
assert CapBenchEquivalent_cap002286 { cap002286 iff cap002286c }
check CapBenchEquivalent_cap002286 for 4
