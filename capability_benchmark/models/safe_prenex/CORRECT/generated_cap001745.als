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

pred cap001745 { ((all x: CapBenchA | x->x in capBenchR) or (inv4 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB))) }
pred cap001745c { (all x: CapBenchA | (x->x in capBenchR or (inv4 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB)))) }
assert CapBenchEquivalent_cap001745 { cap001745 iff cap001745c }
check CapBenchEquivalent_cap001745 for 4
