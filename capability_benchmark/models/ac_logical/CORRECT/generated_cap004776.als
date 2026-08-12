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

pred inv1 {
all p:Person | p in Student
}

pred inv1c {
  Person in Student
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004776 { not ((inv1 and ((some capBenchR and no CapBenchA) or some capBenchR)) and ((some CapBenchB or some CapBenchA) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap004776c { ((not ((some CapBenchB or some CapBenchA) or CapBenchA in CapBenchA + CapBenchB)) or (not (inv1 and ((some capBenchR and no CapBenchA) or some capBenchR)))) }
assert CapBenchEquivalent_cap004776 { cap004776 iff cap004776c }
check CapBenchEquivalent_cap004776 for 4
