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

pred cap002149 { no x: CapBenchA | (x->x in capBenchR and (inv4 and ((some capBenchS or no CapBenchA) or no CapBenchA))) }
pred cap002149c { all x: CapBenchA | not (x->x in capBenchR and (inv4 and ((some capBenchS or no CapBenchA) or no CapBenchA))) }
assert CapBenchEquivalent_cap002149 { cap002149 iff cap002149c }
check CapBenchEquivalent_cap002149 for 4
