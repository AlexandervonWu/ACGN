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

pred cap004133 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv4 and ((some capBenchS or some CapBenchA) or no CapBenchA))) }
pred cap004133c { some a, b: CapBenchA | (b->a in capBenchR and (inv4 and ((some capBenchS or some CapBenchA) or no CapBenchA))) }
assert CapBenchEquivalent_cap004133 { cap004133 iff cap004133c }
check CapBenchEquivalent_cap004133 for 4
