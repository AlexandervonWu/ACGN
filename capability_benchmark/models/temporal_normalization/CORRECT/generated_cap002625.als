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

pred cap002625 { not (((inv4 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some CapBenchB))) since (((no CapBenchA and some capBenchS) and some capBenchR))) }
pred cap002625c { ((not (inv4 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some CapBenchB))) triggered (not ((no CapBenchA and some capBenchS) and some capBenchR))) }
assert CapBenchEquivalent_cap002625 { cap002625 iff cap002625c }
check CapBenchEquivalent_cap002625 for 4
