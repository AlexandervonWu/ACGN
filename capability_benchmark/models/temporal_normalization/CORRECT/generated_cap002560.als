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

pred cap002560 { not always ((inv4 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some CapBenchA))) }
pred cap002560c { eventually (not (inv4 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some CapBenchA))) }
assert CapBenchEquivalent_cap002560 { cap002560 iff cap002560c }
check CapBenchEquivalent_cap002560 for 4
