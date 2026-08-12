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

pred cap001550 { ((some x: CapBenchA | x->x in capBenchR) and (inv4 and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchA))) }
pred cap001550c { (some x: CapBenchA | (x->x in capBenchR and (inv4 and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchA)))) }
assert CapBenchEquivalent_cap001550 { cap001550 iff cap001550c }
check CapBenchEquivalent_cap001550 for 4
