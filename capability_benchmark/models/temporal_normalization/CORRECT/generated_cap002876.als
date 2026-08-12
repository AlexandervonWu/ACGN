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

pred cap002876 { not (((inv4 and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some capBenchS))) until (((some capBenchS or some capBenchR) or some CapBenchA))) }
pred cap002876c { ((not (inv4 and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some capBenchS))) releases (not ((some capBenchS or some capBenchR) or some CapBenchA))) }
assert CapBenchEquivalent_cap002876 { cap002876 iff cap002876c }
check CapBenchEquivalent_cap002876 for 4
