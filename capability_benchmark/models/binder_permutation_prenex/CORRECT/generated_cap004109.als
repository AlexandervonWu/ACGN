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

pred cap004109 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv4 and ((some capBenchS or some capBenchS) or some CapBenchB))) }
pred cap004109c { some a, b: CapBenchA | (b->a in capBenchR and (inv4 and ((some capBenchS or some capBenchS) or some CapBenchB))) }
assert CapBenchEquivalent_cap004109 { cap004109 iff cap004109c }
check CapBenchEquivalent_cap004109 for 4
