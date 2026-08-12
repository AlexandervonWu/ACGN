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
no (Teacher & Student)
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

pred cap000645 { ((inv3 and ((some CapBenchB or no CapBenchA) or no CapBenchA)) or ((capBenchR in (CapBenchA -> CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and some capBenchR) or ((some capBenchR and some capBenchS) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap000645c { (((capBenchR in (CapBenchA -> CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and some capBenchR) or ((some capBenchR and some capBenchS) or CapBenchA in CapBenchA + CapBenchB) or (inv3 and ((some CapBenchB or no CapBenchA) or no CapBenchA))) }
assert CapBenchEquivalent_cap000645 { cap000645 iff cap000645c }
check CapBenchEquivalent_cap000645 for 4
