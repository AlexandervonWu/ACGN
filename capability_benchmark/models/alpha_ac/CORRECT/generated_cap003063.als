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

pred cap003063 { all x: CapBenchA | (x->x in capBenchR and (inv4 and ((CapBenchA in CapBenchA + CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some CapBenchA)) and ((some capBenchR and some capBenchS) or no CapBenchB)) }
pred cap003063c { all renamed: CapBenchA | (((some capBenchR and some capBenchS) or no CapBenchB) and renamed->renamed in capBenchR and (inv4 and ((CapBenchA in CapBenchA + CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some CapBenchA))) }
assert CapBenchEquivalent_cap003063 { cap003063 iff cap003063c }
check CapBenchEquivalent_cap003063 for 4
