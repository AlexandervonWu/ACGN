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

pred cap003101 { all x: CapBenchA | (x->x in capBenchR and (inv4 and ((some capBenchS or some capBenchR) or some CapBenchB)) and ((no CapBenchA and no CapBenchA) and some capBenchR)) }
pred cap003101c { all renamed: CapBenchA | (((no CapBenchA and no CapBenchA) and some capBenchR) and renamed->renamed in capBenchR and (inv4 and ((some capBenchS or some capBenchR) or some CapBenchB))) }
assert CapBenchEquivalent_cap003101 { cap003101 iff cap003101c }
check CapBenchEquivalent_cap003101 for 4
