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

pred cap001288 { all x, y: CapBenchA | (x->y in capBenchR and (inv4 and ((some CapBenchA and some capBenchR) or some capBenchR))) }
pred cap001288c { all a, b: CapBenchA | (b->a in capBenchR and (inv4 and ((some CapBenchA and some capBenchR) or some capBenchR))) }
assert CapBenchEquivalent_cap001288 { cap001288 iff cap001288c }
check CapBenchEquivalent_cap001288 for 4
