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

pred cap000774 { (some (((CapBenchA + CapBenchB) & CapBenchA) & CapBenchA) and (inv4 and ((no CapBenchA and no CapBenchA) and some capBenchR))) }
pred cap000774c { (some ((CapBenchA + CapBenchB) & (CapBenchA & CapBenchA)) and (inv4 and ((no CapBenchA and no CapBenchA) and some capBenchR))) }
assert CapBenchEquivalent_cap000774 { cap000774 iff cap000774c }
check CapBenchEquivalent_cap000774 for 4
