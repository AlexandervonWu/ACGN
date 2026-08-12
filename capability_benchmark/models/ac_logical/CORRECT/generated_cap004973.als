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

pred inv3 {
no p:Person | p in Teacher and p in Student
}

pred inv3c {
 no Student & Teacher 
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004973 { not ((inv3 and ((some CapBenchB or no CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and no CapBenchA)) }
pred cap004973c { ((not ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and no CapBenchA)) or (not (inv3 and ((some CapBenchB or no CapBenchB) or CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap004973 { cap004973 iff cap004973c }
check CapBenchEquivalent_cap004973 for 4
