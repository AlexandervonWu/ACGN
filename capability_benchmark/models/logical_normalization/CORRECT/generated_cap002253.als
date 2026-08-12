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

pred cap002253 { not ((inv1 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or no CapBenchB)) and ((no CapBenchA and some capBenchS) and capBenchR in (CapBenchA -> CapBenchA))) }
pred cap002253c { ((not (inv1 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or no CapBenchB))) or (not ((no CapBenchA and some capBenchS) and capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap002253 { cap002253 iff cap002253c }
check CapBenchEquivalent_cap002253 for 4
