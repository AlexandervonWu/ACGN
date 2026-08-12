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

pred cap000669 { ((inv3 and ((some CapBenchB or some capBenchS) or no CapBenchA)) or ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some capBenchS) or ((some capBenchR and some CapBenchA) or some CapBenchA)) }
pred cap000669c { (((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some capBenchS) or ((some capBenchR and some CapBenchA) or some CapBenchA) or (inv3 and ((some CapBenchB or some capBenchS) or no CapBenchA))) }
assert CapBenchEquivalent_cap000669 { cap000669 iff cap000669c }
check CapBenchEquivalent_cap000669 for 4
